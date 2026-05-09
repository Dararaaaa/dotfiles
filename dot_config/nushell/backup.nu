module backup {
    # Function to backup a file
    export def backup-file [
        file_path: path,
        backup_dir: path
    ] {
        # Ensure the backup directory exists
        mkdir $backup_dir

        # Get the current date and time for timestamping the backup
        let date_time = (date now | date format "%Y%m%d_%H%M%S")

        # Extract the file name and extension
        let file_name = (path basename $file_path)
        let extension = (path extension $file_path)

        # Create the backup file name with a timestamp
        let backup_file = ($backup_dir / ($file_name + "_" + $date_time + if $extension != "" { "." + $extension } else { "" }))

        # Copy the file to the backup directory
        cp $file_path $backup_file

        # Confirm the backup was created
        echo $"Backup of ($file_path) created at ($backup_file)"
    }

    # Function to restore the most recent backup of a file
    export def restore-file [
        file_name: string,
        backup_dir: path,
        restore_dir: path
    ] {
        # Find all backup files matching the file name pattern
        let backup_files = (ls $backup_dir | where name =~ $file_name)

        # Check if there are any backup files
        if ($backup_files | empty?) {
            echo $"No backup files found for ($file_name) in ($backup_dir)"
            return
        }

        # Find the most recent backup file
        let latest_backup = ($backup_files | sort-by modified | last | get name)
        let restore_file = ($backup_dir / $latest_backup)

        # Ensure the restore directory exists
        mkdir $restore_dir

        # Copy the backup file to the restore directory
        cp $restore_file ($restore_dir / (path basename $restore_file))

        # Confirm the restore was completed
        echo $"Backup ($restore_file) restored to ($restore_dir)"
    }
}

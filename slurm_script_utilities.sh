
slurm_script_path () {
    # PURPOSE: Returns the path to the slurm script.
    # ARGUMENTS: Takes no positional arguments.
    # SIDE EFFECTS: Echoes the slurm script path to stdout.

    # ----------------------------------------------------
    # Define the variable script_path for the path to this
    # Slurm batch file.
    # ----------------------------------------------------
    local script_path=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/ {print $2}')

    # ----------------------------------------------------
    # Echo variable script_path stdout.
    # ----------------------------------------------------
    echo "${script_path}"
}

slurm_script_name () {
    # PURPOSE: Returns the name to the slurm script.
    # ARGUMENTS: Takes no positional arguments.
    # SIDE EFFECTS: Echoes the slurm script name to stdout.

    # ----------------------------------------------------
    # Define the variable script_path for the path to the
    # Slurm batch file.
    # ----------------------------------------------------
    local script_path=$(slurm_script_path)

    # ----------------------------------------------------
    # Define the variable script_name for the name to the
    # Slurm batch file.
    # ----------------------------------------------------
    local script_name=$(basename "$script_path")
    
    # ----------------------------------------------------
    # Echo variable script_name stdout.
    # ----------------------------------------------------
    echo "${script_name}"
}

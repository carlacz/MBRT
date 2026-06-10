# -------------------------------------------------------------------------
# Title:    Data preparation - MBRT PsychoPy local
# Author:   Carla Czilczer
# Date:     04.06.2026
# R ver.:   4.5.2
#
# Purpose:
# Prepare PsychoPy experiment output (.csv files) so that:
# - trial-level data are available in long format (data_long_tbl)
# - demographic data are summarized in wide format (data_wide)
#
# Usage:
# Place this script next to a folder named "data".
# Place all PsychoPy .csv files in that "data" folder.
# The script writes data.rdata containing data_long_tbl and data_wide.
# -------------------------------------------------------------------------

# =========================================================================
# PREPARATIONS
# =========================================================================

# Clear workspace
rm(list = ls())

# -------- Set working directory to the fixed 'data' folder next to this script --------
# This assumes you run the script from the folder where it is saved.
# If a folder called "data" exists there, the script switches into it.

if (dir.exists("data")) {
  setwd("data")
}

message("Working directory: ", normalizePath(getwd()))

# -------- Workflow: read multiple PsychoPy CSV files and merge --------

csv_pattern <- "\\.csv$"
files <- list.files(pattern = csv_pattern, full.names = TRUE)

if (length(files) == 0L) {
  stop("No CSV files found. Put your PsychoPy .csv files into the data folder.")
}

# Read one CSV file safely.
# Empty or unreadable files are skipped.
read_one_file <- function(f) {
  x <- tryCatch(
    read.csv(f, stringsAsFactors = FALSE, check.names = TRUE),
    error = function(e) NULL
  )
  
  if (is.null(x) || nrow(x) == 0L) {
    warning("Skipping empty/unreadable file: ", basename(f))
    return(NULL)
  }
  
  names(x) <- trimws(names(x))
  x$source_file <- rep(basename(f), nrow(x))
  x
}

data_list <- lapply(files, read_one_file)
data_list <- Filter(Negate(is.null), data_list)

if (length(data_list) == 0L) {
  stop("No usable CSV files found. All matching CSV files were empty or unreadable.")
}

# Combine files even if PsychoPy files differ slightly in their columns.
# Missing columns are filled with NA before row-binding.
all_cols <- unique(unlist(lapply(data_list, names)))

data_list <- lapply(data_list, function(x) {
  missing_cols <- setdiff(all_cols, names(x))
  if (length(missing_cols) > 0L) {
    for (col in missing_cols) x[[col]] <- NA
  }
  x[, all_cols, drop = FALSE]
})

df <- do.call(rbind, data_list)

message("Imported ", length(data_list), " usable file(s). Combined rows: ", nrow(df),
        " | columns: ", ncol(df))

# ==========================================================================
# DATA WRANGLING
# ==========================================================================

# -------- Participant ID ---------------------------------------------------
# PsychoPy usually stores the participant ID in 'participant'.
# For comparability with the OpenSesame script, this is renamed to subject_nr.

if ("participant" %in% names(df)) {
  df$subject_nr <- as.character(df$participant)
} else if ("subject_nr" %in% names(df)) {
  df$subject_nr <- as.character(df$subject_nr)
} else {
  stop("Required participant ID column missing. Expected 'participant' or 'subject_nr'.")
}

# -------- Demographics (wide) ----------------------------------------------
# Create one row per subject with first non-empty value for each demographic field.
# PsychoPy column names are mapped to the same output names as before.

first_nonempty <- function(x) {
  x <- as.character(x)
  x <- trimws(x)
  x <- x[!is.na(x) & nzchar(x)]
  if (length(x) >= 1L) x[[1]] else NA_character_
}

subjects <- unique(df$subject_nr)
data_wide <- data.frame(subject_nr = subjects, stringsAsFactors = FALSE)

if ("age_textbox.text" %in% names(df)) {
  data_wide$age <- vapply(subjects, function(s) {
    first_nonempty(df$age_textbox.text[df$subject_nr == s])
  }, FUN.VALUE = character(1), USE.NAMES = FALSE)
  
  data_wide$age <- suppressWarnings(as.integer(as.numeric(data_wide$age)))
}

if ("gender_slider.response" %in% names(df)) {
  data_wide$gender <- vapply(subjects, function(s) {
    first_nonempty(df$gender_slider.response[df$subject_nr == s])
  }, FUN.VALUE = character(1), USE.NAMES = FALSE)
  
  # PsychoPy stores this slider response numerically in the CSV.
  # Coding:
  # female = 1, male = 2, transgender = 3, nonbinary = 4, other = 5, none = 6
  data_wide$gender <- suppressWarnings(as.integer(as.numeric(data_wide$gender)))
}

if ("laterality_slider.response" %in% names(df)) {
  data_wide$handedness <- vapply(subjects, function(s) {
    first_nonempty(df$laterality_slider.response[df$subject_nr == s])
  }, FUN.VALUE = character(1), USE.NAMES = FALSE)
  
  # PsychoPy stores this slider response numerically in the CSV.
  # Coding:
  # left = 1, ambidextrous = 2, right = 3
  data_wide$handedness <- suppressWarnings(as.integer(as.numeric(data_wide$handedness)))
}

message("Created demographic table with ", nrow(data_wide), " participant(s).")

# -------- Rename raw logger columns to short names (if present) -------------
# PsychoPy names seen in the experiment:
# - mbrt_correct_response
# - response_time_trial_response
# - response_trial_response

rename_if_exists <- function(df, old, new) {
  if (old %in% names(df)) names(df)[names(df) == old] <- new
  df
}

df <- rename_if_exists(df, "mbrt_correct_response", "mbrt_correct")
df <- rename_if_exists(df, "response_time_trial_response", "mbrt_rt")
df <- rename_if_exists(df, "response_trial_response", "trial_response")

# -------- Create trial-level (long) table ---------------------------------
# Keep only MBRT test trials.
# If trial_response exists, also remove rows without a response.

if (!"phase" %in% names(df)) {
  stop("Required column 'phase' missing. Cannot identify MBRT_testblock rows.")
}

data_long_tbl <- df[df$phase == "MBRT_testblock", , drop = FALSE]

if ("trial_response" %in% names(data_long_tbl)) {
  data_long_tbl <- data_long_tbl[
    !is.na(data_long_tbl$trial_response) & data_long_tbl$trial_response != "",
    , drop = FALSE
  ]
}

message("Filtered to MBRT_testblock: ", nrow(data_long_tbl), " trial row(s).")

# -------- Keep only relevant columns (if they exist) -----------------------

wanted <- c("subject_nr", "phase", "n_testbl", "n_trial",
            "mbrt_correct", "solution", "mbrt_angle", "mbrt_limb", "mbrt_side",
            "mbrt_view", "mbrt_rt", "trial_response", "source_file")

available <- intersect(wanted, names(data_long_tbl))
missing <- setdiff(wanted, available)

if (length(missing) > 0L) {
  message("Warning: missing columns - they will be omitted: ",
          paste(missing, collapse = ", "))
}

data_long_tbl <- data_long_tbl[, available, drop = FALSE]

# -------- Type adjustments (simple) ---------------------------------------

if ("subject_nr" %in% names(data_long_tbl)) {
  data_long_tbl$subject_nr <- as.factor(as.character(data_long_tbl$subject_nr))
}

if ("n_testbl" %in% names(data_long_tbl)) {
  data_long_tbl$n_testbl <- suppressWarnings(as.integer(as.numeric(data_long_tbl$n_testbl)))
}

if ("n_trial" %in% names(data_long_tbl)) {
  data_long_tbl$n_trial <- suppressWarnings(as.integer(as.numeric(data_long_tbl$n_trial)))
}

if ("mbrt_correct" %in% names(data_long_tbl)) {
  data_long_tbl$mbrt_correct <- suppressWarnings(as.integer(as.numeric(data_long_tbl$mbrt_correct)))
}

if ("mbrt_angle" %in% names(data_long_tbl)) {
  data_long_tbl$mbrt_angle <- suppressWarnings(as.numeric(data_long_tbl$mbrt_angle))
}

if ("mbrt_rt" %in% names(data_long_tbl)) {
  data_long_tbl$mbrt_rt <- suppressWarnings(as.numeric(data_long_tbl$mbrt_rt))
}

for (col in c("mbrt_limb", "mbrt_side", "mbrt_view")) {
  if (col %in% names(data_long_tbl)) {
    data_long_tbl[[col]] <- as.factor(data_long_tbl[[col]])
  }
}

# -------- Variable documentation ------------------------------------------
# data_long_tbl (one row per trial) - columns (name : description : type):
#  - subject_nr    : participant ID : factor
#  - phase         : experiment phase (e.g. "MBRT_testblock", "MBRT_practice") : character
#  - n_testbl      : test block index : integer
#  - n_trial       : trial index : integer
#  - mbrt_correct  : correctness flag (1 = correct, 0 = incorrect) : integer (0/1)
#  - solution      : correct response code for the trial : character
#  - mbrt_angle    : stimulus rotation : numeric
#  - mbrt_limb     : limb shown : factor
#  - mbrt_side     : laterality ("left", "right") : factor
#  - mbrt_view     : view ("front", "back") : factor
#  - mbrt_rt       : response time : numeric
#  - trial_response: key pressed / participant response : character
#  - source_file   : source CSV filename : character
#
# data_wide: one row per subject with demographic fields:
#  - subject_nr : participant ID : character
#  - age        : participant age in years : integer
#  - gender     : participant gender coded as integer
#                 (female = 1, male = 2, transgender = 3, nonbinary = 4,
#                  other = 5, none = 6) : integer
#  - handedness : participant handedness/laterality coded as integer
#                 (left = 1, ambidextrous = 2, right = 3) : integer

# -------- Save results ----------------------------------------------------

output_file <- "data.rdata"
save(data_long_tbl, data_wide, file = output_file)

message("Saved data_long_tbl and data_wide to: ", file.path(getwd(), output_file))
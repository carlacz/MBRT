# -------------------------------------------------------------------------
# Title:    Data preparation - MBRT OpenSesame PsychoPy (Desktop)
# Author:   Carla Czilczer
# Date:     16.12.2025
# R ver.:   4.5.2
#
# Purpose:
# Prepare experiment output (CSV from OpenSesame PsychoPy) so that:
# - trial-level data are available in long format (data_long_tbl)
# - demographic data are summarized in wide format (data_wide)
#
# Usage:
# Set the data_file variable below to point to your CSV file from OpenSesame.
# The script writes data.rdata containing data_long_tbl and data_wide.
# -------------------------------------------------------------------------

# =========================================================================
# PREPARATIONS
# =========================================================================
# Clear workspace
rm(list = ls())

# -------- Set data file path ---------------------------------------------
# UPDATE THIS PATH to point to your OpenSesame CSV output file
data_file <- "subject-0.csv"  # Change this to your data file name/path

# -------- Set working directory ------------------------------------------
# Optionally set working directory to where your data file is located
# setwd("path/to/your/data/folder")

# -------- Read input -----------------------------------------------------
if (!file.exists(data_file)) {
  stop("Input file not found: '", data_file, "'\n",
       "Please update the 'data_file' variable at the top of this script ",
       "to point to your OpenSesame CSV output file.")
}

df <- tryCatch(
  read.csv(data_file, stringsAsFactors = FALSE),
  error = function(e) stop("Failed to read CSV: ", e$message, call. = FALSE)
)

message("Loaded ", nrow(df), " rows and ", ncol(df), " columns from: ", data_file)

# ==========================================================================
# DATA WRANGLING
# ==========================================================================
# -------- Demographics (wide) ----------------------------------------------
# Create one row per subject with first non-empty value for each demographic field
# Only build data_wide if demographic columns are present
if (!"subject_nr" %in% names(df)) stop("Required column 'subject_nr' missing.")

dem_cols <- intersect(c("age", "sex", "handedness"), names(df))

if (length(dem_cols) > 0) {
  subjects <- unique(as.character(df$subject_nr))
  data_wide <- data.frame(subject_nr = subjects, stringsAsFactors = FALSE)

  for (col in dem_cols) {
    vals <- vapply(subjects, function(s) {
      v <- df[df$subject_nr == s, col]
      v <- v[!is.na(v) & nzchar(as.character(v))]
      if (length(v) >= 1L) as.character(v[[1]]) else NA_character_
    }, FUN.VALUE = character(1), USE.NAMES = FALSE)
    data_wide[[col]] <- vals
  }

  # Post-process common types (if present)
  if ("age" %in% names(data_wide)) data_wide$age <- suppressWarnings(as.integer(data_wide$age))
  if ("sex" %in% names(data_wide)) data_wide$sex <- tolower(as.character(data_wide$sex))
  if ("handedness" %in% names(data_wide)) data_wide$handedness <- tolower(as.character(data_wide$handedness))

  message("Created demographic table with ", nrow(data_wide), " participants.")
} else {
  message("No demographic columns (age, sex, handedness) found. Skipping data_wide creation.")
  data_wide <- NULL
}

# -------- Rename raw logger columns to short names (if present) -------------
# raw names seen in the experiment: correct_response, response_time_trial_response, response_trial_response
rename_if_exists <- function(df, old, new) {
  if (old %in% names(df)) names(df)[names(df) == old] <- new
  df
}
df <- rename_if_exists(df, "correct_response", "correct")
df <- rename_if_exists(df, "response_time_trial_response", "RT")
df <- rename_if_exists(df, "response_trial_response", "trial_response")

# -------- Keep only relevant columns (if they exist) -----------------------
wanted <- c("subject_nr", "phase", "n_testbl", "n_trial",
            "correct", "solution", "mbrt_angle", "mbrt_limb", "mbrt_side",
            "mbrt_view", "RT", "trial_response")
available <- intersect(wanted, names(df))
if (length(setdiff(wanted, available)) > 0) {
  message("Note: some columns not found - they will be omitted: ",
          paste(setdiff(wanted, available), collapse = ", "))
}
df <- df[, available, drop = FALSE]

# -------- Type adjustments (simple) ---------------------------------------
if ("subject_nr" %in% names(df)) df$subject_nr <- as.factor(as.character(df$subject_nr))
for (c in c("mbrt_limb", "mbrt_side", "mbrt_view")) {
  if (c %in% names(df)) df[[c]] <- as.factor(df[[c]])
}
if ("mbrt_angle" %in% names(df)) df$mbrt_angle <- suppressWarnings(as.numeric(df$mbrt_angle))

# -------- Create trial-level (long) table ---------------------------------
if ("phase" %in% names(df)) {
  data_long_tbl <- subset(df, phase == "MBRT_testblock")
  message("Filtered to MBRT_testblock: ", nrow(data_long_tbl), " rows.")
} else {
  data_long_tbl <- df
  message("No 'phase' column found: returning all rows as data_long_tbl.")
}

# -------- Variable documentation ------------------------------------------
# data_long_tbl (one row per trial) - columns (name : description : type):
#  - subject_nr    : participant ID : factor
#  - phase         : experiment phase (e.g. "MBRT_testblock", "MBRT_practice") : character
#  - n_testbl      : test block index (1-4 if >1 repetitions selected in experiment) : integer
#  - n_trial       : trial index (within test phase) : integer
#  - correct       : correctness flag (1 = correct, 0 = incorrect) : integer (0/1)
#  - solution      : correct response code for the trial (e.g. "s", "g", "l", "h") : character
#  - mbrt_angle    : stimulus rotation (degrees or label) : numeric
#  - mbrt_limb     : limb shown (e.g., "arm", "leg") : factor
#  - mbrt_side     : laterality ("left", "right") : factor
#  - mbrt_view     : view ("front", "back") : factor
#  - RT            : response time in milliseconds : numeric (ms)
#  - trial_response: key pressed / response code (participant response) : character
#
# data_wide (if demographics were included): one row per subject with demographic fields:
#  - subject_nr : participant ID : character
#  - age        : participant age in years : integer (years)
#  - sex        : participant sex : character with allowed values:
#                 "f" = female, "m" = male, "d" = diverse
#  - handedness : participant handedness : character with allowed values:
#                 "l" = left, "r" = right

# -------- Save results ----------------------------------------------------
output_file <- "data.rdata"
if (!is.null(data_wide)) {
  save(data_long_tbl, data_wide, file = output_file)
  message("Saved data_long_tbl and data_wide to: ", file.path(getwd(), output_file))
} else {
  save(data_long_tbl, file = output_file)
  message("Saved data_long_tbl to: ", file.path(getwd(), output_file))
  message("(data_wide was not created because no demographic columns were found)")
}

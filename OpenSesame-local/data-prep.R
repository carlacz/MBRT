# -------------------------------------------------------------------------
# Title:    Data preparation - MBRT OpenSesame local
# Author:   Carla Czilczer
# Date:     17.12.2025
# R ver.:   4.5.2
#
# Purpose:
# Prepare experiment output (.csv files) so that:
# - trial-level data are available in long format (data_long_tbl)
# - demographic data are summarized in wide format (data_wide)
#
# Usage:
# Place the subject-x.csv files in the working directory (or setwd() before running).
# The script writes data.rdata containing data_long_tbl and data_wide.
# -------------------------------------------------------------------------

# =========================================================================
# PREPARATIONS
# =========================================================================
# Clear workspace
rm(list = ls())

# -------- Set working directory to the fixed 'data' folder next to this script --------
# The script expects a folder named "data" next to this script.
# Do not move or rename that folder.

script_path <- NULL

# 1) If run with Rscript --file=..., get that path
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) > 0L) script_path <- sub("^--file=", "", file_arg[1])

# 2) Try to get the path from sys.frames (works when sourced)
if (is.null(script_path)) {
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (!is.null(of) && nzchar(of)) script_path <- of
}

# 3) Try RStudio editor path (common for non-programmers using RStudio)
if (is.null(script_path) &&
    requireNamespace("rstudioapi", quietly = TRUE) &&
    rstudioapi::isAvailable()) {
  p <- rstudioapi::getActiveDocumentContext()$path
  if (nzchar(p)) script_path <- p
}

# Build data folder path: <script_dir>/data ; if script path unknown, use cwd/data
if (!is.null(script_path)) {
  script_dir <- dirname(normalizePath(script_path))
  data_dir <- file.path(script_dir, "data")
} else {
  message("Could not determine script location. Using current working directory + /data as fallback.")
  data_dir <- file.path(getwd(), "data")
}

# Enforce that the data folder exists next to this script
if (!dir.exists(data_dir)) {
  stop("Required 'data' folder not found next to this script:\n  ",
       normalizePath(if (!is.null(script_path)) script_dir else getwd()),
       "\nPlease ensure the repository was decompressed and the 'data' folder is present next to the script. Do not move the data folder.")
}

setwd(data_dir)
message("Working directory set to data folder: ", normalizePath(getwd()))

# -------- Workflow: read multiple subject-*.csv files and merge --------

# Pattern for your multiple files (adapt if needed)
csv_pattern <- "^subject-.*\\.csv$"

files <- list.files(pattern = csv_pattern, full.names = TRUE)

if (length(files) == 0) {
  stop("No matching CSV files found in: ", normalizePath(getwd()),
       "\nExpected something like 'subject-1.csv', 'subject-2.csv', ...",
       "\nPattern used: ", csv_pattern)
}

# Ensure dplyr is available for robust row-binding
if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required for bind_rows(). Please install it via:\n",
       "install.packages('dplyr')")
}

data_list <- lapply(files, function(f) {
  df <- read.csv(f, stringsAsFactors = FALSE)
  names(df) <- trimws(names(df))
  df$source_file <- basename(f)  # optional but useful provenance column
  df
})

df <- dplyr::bind_rows(data_list)

message("Imported ", length(files), " file(s). Combined rows: ", nrow(df),
        " | columns: ", ncol(df))

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
  message("Warning: missing columns - they will be omitted: ",
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

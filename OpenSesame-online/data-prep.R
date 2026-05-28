# -------------------------------------------------------------------------
# Title:    Data preparation - MBRT OpenSesame online
# Author:   Carla Czilczer
# Date:     15.12.2025
# R ver.:   4.5.2
#
# Purpose:
# Prepare experiment output (JSON in data.txt) so that:
# - trial-level data are available in long format (data_long_tbl)
# - demographic data are summarized in wide format (data_wide)
#
# Usage:
# Place data.txt in the folder "data" located next to this script:
#
# OpenSesame-online/
# ├── data-prep.R
# └── data/
#     └── data.txt
#
# Run this script using "Source" in RStudio.
# The script writes data.rdata into the same "data" folder.
# -------------------------------------------------------------------------


# =========================================================================
# PREPARATIONS
# =========================================================================

# Clear workspace
rm(list = ls())


# -------- Dependencies (install if missing) -------------------------------

if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite", repos = "https://cloud.r-project.org")
}

library(jsonlite)


# -------- Locate the data folder next to this script -----------------------

# Determine the location of the running script.
# This works when the complete script is run using "Source" in RStudio
# or using Rscript.
script_file <- NULL

# Case 1: Script executed using Rscript
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)

if (length(file_arg) > 0L) {
  script_file <- sub("^--file=", "", file_arg[1])
}

# Case 2: Script executed using Source in RStudio
if (is.null(script_file)) {
  frames <- sys.frames()
  
  script_candidates <- vapply(
    frames,
    function(x) {
      if (!is.null(x$ofile)) {
        as.character(x$ofile)
      } else {
        NA_character_
      }
    },
    FUN.VALUE = character(1)
  )
  
  script_candidates <- script_candidates[
    !is.na(script_candidates) & nzchar(script_candidates)
  ]
  
  if (length(script_candidates) > 0L) {
    script_file <- tail(script_candidates, 1)
  }
}

if (is.null(script_file)) {
  stop(
    "Could not determine the location of this script.\n",
    "Please save the script and run the complete script using 'Source' in RStudio."
  )
}

script_dir <- dirname(normalizePath(script_file))
data_dir <- file.path(script_dir, "data")
input_file <- file.path(data_dir, "data.txt")
output_file <- file.path(data_dir, "data.rdata")


# -------- Check input location ---------------------------------------------

if (!dir.exists(data_dir)) {
  stop(
    "Required folder 'data' not found next to this script:\n",
    data_dir,
    "\n\nPlease create or restore the folder structure:\n",
    "OpenSesame-online/\n",
    "├── data-prep.R\n",
    "└── data/\n",
    "    └── data.txt"
  )
}

if (!file.exists(input_file)) {
  stop(
    "Input file not found:\n",
    input_file,
    "\n\nPlease place the JATOS export file named 'data.txt' ",
    "inside the folder 'data' next to this script."
  )
}

message("Reading input file: ", normalizePath(input_file))


# -------- Read input -------------------------------------------------------

# The JATOS export contains one separate JSON object per line.
json_lines <- readLines(
  input_file,
  warn = FALSE,
  encoding = "UTF-8"
)

# Remove empty lines if present.
json_lines <- json_lines[nzchar(trimws(json_lines))]

if (length(json_lines) == 0L) {
  stop("Input file is empty: ", input_file)
}

# Read each JSON object separately.
json <- tryCatch(
  lapply(json_lines, fromJSON, flatten = TRUE),
  error = function(e) {
    stop("Failed to read JSON: ", e$message, call. = FALSE)
  }
)

if (any(vapply(json, function(x) is.null(x$data), logical(1)))) {
  stop("At least one JSON object does not contain a top-level 'data' element.")
}

# Combine trial data from all JSON objects.
df <- jsonlite::rbind_pages(
  lapply(json, function(x) {
    as.data.frame(x$data, stringsAsFactors = FALSE)
  })
)

message("Loaded ", nrow(df), " rows and ", ncol(df), " columns.")


# ==========================================================================
# DATA WRANGLING
# ==========================================================================

# -------- Demographics (wide) ----------------------------------------------

# Create one row per subject with first non-empty value for each
# demographic field.
# Only build data_wide if demographic columns are present.

if (!"subject_nr" %in% names(df)) {
  stop("Required column 'subject_nr' missing.")
}

dem_cols <- intersect(c("age", "sex", "handedness"), names(df))

if (length(dem_cols) > 0) {
  
  subjects <- unique(as.character(df$subject_nr))
  
  data_wide <- data.frame(
    subject_nr = subjects,
    stringsAsFactors = FALSE
  )
  
  for (col in dem_cols) {
    
    vals <- vapply(
      subjects,
      function(s) {
        v <- df[df$subject_nr == s, col]
        v <- v[!is.na(v) & nzchar(as.character(v))]
        
        if (length(v) >= 1L) {
          as.character(v[[1]])
        } else {
          NA_character_
        }
      },
      FUN.VALUE = character(1),
      USE.NAMES = FALSE
    )
    
    data_wide[[col]] <- vals
  }
  
  # Post-process common types if present.
  if ("age" %in% names(data_wide)) {
    data_wide$age <- suppressWarnings(as.integer(data_wide$age))
  }
  
  if ("sex" %in% names(data_wide)) {
    data_wide$sex <- tolower(as.character(data_wide$sex))
  }
  
  if ("handedness" %in% names(data_wide)) {
    data_wide$handedness <- tolower(as.character(data_wide$handedness))
  }
  
  message(
    "Created demographic table with ",
    nrow(data_wide),
    " participants."
  )
  
} else {
  
  message(
    "No demographic columns (age, sex, handedness) found. ",
    "Skipping data_wide creation."
  )
  
  data_wide <- NULL
}


# -------- Rename raw logger columns to short names if present --------------

# Raw names seen in the experiment:
# mbrt_correct_response, response_time_trial_response,
# response_trial_response

rename_if_exists <- function(df, old, new) {
  if (old %in% names(df)) {
    names(df)[names(df) == old] <- new
  }
  
  df
}

df <- rename_if_exists(df, "mbrt_correct_response", "mbrt_correct")
df <- rename_if_exists(df, "response_time_trial_response", "RT")
df <- rename_if_exists(df, "response_trial_response", "trial_response")


# -------- Keep only relevant columns if they exist ------------------------

wanted <- c(
  "subject_nr",
  "phase",
  "n_testbl",
  "n_trial",
  "mbrt_correct",
  "solution",
  "mbrt_angle",
  "mbrt_limb",
  "mbrt_side",
  "mbrt_view",
  "RT",
  "trial_response"
)

available <- intersect(wanted, names(df))

if (length(setdiff(wanted, available)) > 0) {
  message(
    "Warning: missing columns - they will be omitted: ",
    paste(setdiff(wanted, available), collapse = ", ")
  )
}

df <- df[, available, drop = FALSE]


# -------- Type adjustments (simple) ---------------------------------------

if ("subject_nr" %in% names(df)) {
  df$subject_nr <- as.factor(as.character(df$subject_nr))
}

for (c in c("mbrt_limb", "mbrt_side", "mbrt_view")) {
  if (c %in% names(df)) {
    df[[c]] <- as.factor(df[[c]])
  }
}

if ("mbrt_angle" %in% names(df)) {
  df$mbrt_angle <- suppressWarnings(as.numeric(df$mbrt_angle))
}


# -------- Create trial-level (long) table ---------------------------------

if ("phase" %in% names(df)) {
  
  data_long_tbl <- subset(df, phase == "MBRT_testblock")
  
  message(
    "Filtered to MBRT_testblock: ",
    nrow(data_long_tbl),
    " rows."
  )
  
} else {
  
  data_long_tbl <- df
  
  message(
    "No 'phase' column found: returning all rows as data_long_tbl."
  )
}


# -------- Variable documentation ------------------------------------------

# data_long_tbl (one row per trial) - columns (name : description : type):
#
#  - subject_nr    : participant ID : factor
#  - phase         : experiment phase
#                    (e.g. "MBRT_testblock", "MBRT_practice") : character
#  - n_testbl      : test block index
#                    (1-4 if >1 repetitions selected in experiment) : integer
#  - n_trial       : trial index within test phase : integer
#  - mbrt_correct  : correctness flag
#                    (1 = correct, 0 = incorrect) : integer (0/1)
#  - solution      : correct response code for the trial
#                    (e.g. "s", "g", "l", "h") : character
#  - mbrt_angle    : stimulus rotation (degrees or label) : numeric
#  - mbrt_limb     : limb shown (e.g. "arm", "leg") : factor
#  - mbrt_side     : laterality ("left", "right") : factor
#  - mbrt_view     : view ("front", "back") : factor
#  - RT            : response time in milliseconds : numeric (ms)
#  - trial_response: key pressed / response code
#                    (participant response) : character
#
# data_wide (if demographics were included):
# one row per subject with demographic fields:
#
#  - subject_nr : participant ID : character
#  - age        : participant age in years : integer (years)
#  - sex        : participant sex : character with allowed values:
#                 "f" = female, "m" = male, "d" = diverse
#  - handedness : participant handedness : character with allowed values:
#                 "l" = left, "r" = right


# -------- Save results ----------------------------------------------------

if (!is.null(data_wide)) {
  
  save(
    data_long_tbl,
    data_wide,
    file = output_file
  )
  
  message(
    "Saved data_long_tbl and data_wide to: ",
    normalizePath(output_file, mustWork = FALSE)
  )
  
} else {
  
  save(
    data_long_tbl,
    file = output_file
  )
  
  message(
    "Saved data_long_tbl to: ",
    normalizePath(output_file, mustWork = FALSE)
  )
  
  message(
    "(data_wide was not created because no demographic columns were found)"
  )
}


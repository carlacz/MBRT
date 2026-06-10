# MENTAL BODY ROTATION TASK (MBRT)

**Author:** Carla Czilczer, 10/06/2026  
**Software used:** PsychoPy 2025.1.1  
**Experiment Type:** Online
**Languages supported:** English (EN) = default, German (DE), Spanish (ES) and French (FR). Further languages can be added, which requires simple changes in the code and updating the `.xlsx` files (see [language localization](#LANGUAGE-LOCALIZATION)). 

---------------------------------------

## GENERAL INSTRUCTIONS

This experiment is built using [PsychoPy](https://www.psychopy.org/) (Builder) 2025.1.1. To run this experiment online, it utilizes PsychoPy’s **PsychoJS** export and is typically hosted via [Pavlovia](https://pavlovia.org/). Please check the version you are using, as older PsychoPy / PsychoJS versions might crash or behave unexpectedly.  
If you are unfamiliar with PsychoPy, please refer to the [documentation](https://www.psychopy.org/documentation.html) on their website. This README specifically details the structure and customization of this **MBRT** implementation.

---------------------------------------

## SETUP INSTRUCTIONS

To edit or run this task, you need to have **PsychoPy** installed.  
To run the task online, you will need a hosting solution for PsychoJS (most commonly **Pavlovia**).  
PsychoPy exports results directly as `.csv` (wide format) plus `.log` / `.psydat` (depending on run mode).
A script for data preparation in [R](https://www.r-project.org/) (4.5.2) is provided.

**Step-by-step instructions:**
1. **Download** and unzip the repository to a dedicated folder.
2. **Open PsychoPy**, then open the experiment file `MBRT_online.psyexp` in Builder.
3. To run online, use PsychoPy’s **Pavlovia** workflow (e.g., “Pavlovia → Sync” / “Export HTML”), and follow the standard PsychoPy/Pavlovia procedure to create/sync a Pavlovia project.
4. Click the **Run** button to test in browser (debugging only; not recommended for online data collection).
5. **Distribute** the generated study link to your participants. They run the task directly in their web browser.
6. **Download the data** from the Pavlovia project dashboard (Results/Data export).
7. **Place all downloaded `.csv` files** in the `data` folder located inside the unzipped repository. The `data-prep.R` script reads all `.csv` files in this folder automatically.
8. **Process the data** using the provided `data-prep.R` script.

---------------------------------------

## LANGUAGE LOCALIZATION

This experiment uses external spreadsheet files to manage text and translations. This makes adding new languages relatively easy, but strict formatting rules apply.

Participants select their preferred language via the PsychoPy startup dialog (Experiment Info; see [Experiment settings](#experiment-settings-parameters-to-choose)). The experiment then uses the corresponding _ISO_code_ (e.g., `EN`, `DE`) to retrieve the corresponding text from columns in the external message sheet.

- `Language_localiser.xlsx` maps a **language** to an **ISO_code**.
- The message sheet (e.g., `MBRT_files/Messages.xlsx`) contains one column per ISO_code (e.g., `EN`, `DE`) and is iterated to populate the global text variables used across routines.

### Adding a new language

#### 1. Open the relevant files
- `Language_localiser.xlsx`
- `MBRT_files/Messages.xlsx`

#### 2. Extend `Language_localiser.xlsx` by adding a new row

The file must contain the columns:
- `language`
- `ISO_code`

Example:

| language | ISO_code |
| :--- | :--- |
| English | EN |
| German | DE |

Add your new language (e.g., Italian) in a **new row**:

| language | ISO_code |
| :--- | :--- |
| English | EN |
| German | DE |
| Italian | IT |

#### 3. Extend `MBRT_files/Messages.xlsx` by adding a new column

The file must contain:
- a `message` column (variable names used inside PsychoPy), and
- one column per language (named by _ISO_code_)

Example:

| message | EN | DE |
| :--- | :--- | :--- |
| welcome_msg | Welcome to the task! | Willkommen zur Aufgabe! |
| adv_msg | Press SPACE to continue | Drücken Sie SPACE zum Fortfahren |

Add a **new column** using the ISO code (`IT`) and enter translations:

| message | EN | DE | IT |
| :--- | :--- | :--- | :--- |
| welcome_msg | Welcome to the task! | Willkommen zur Aufgabe! | Benvenuti al compito! |
| adv_msg | Press SPACE to continue | Drücken Sie die LEERTASTE | Premi SPAZIO per continuare |

⚠️ Do this consistently for **all** message keys used by the experiment!

#### 4. Update the experiment

1. Open `MBRT_online.psyexp`
2. Go to **Experiment Settings** (cogwheel icon) → Basic → Experiment info
3. Update the `language` entry by adding your new language name (e.g., `Italian`). It must exactly match the entry in `Language_localiser.xlsx`.
4. Save the experiment.

#### 5. Sync the updated experiment to Pavlovia

Use **Pavlovia → Sync** to rebuild and upload the updated files to the online project. If changes don’t appear, clear your browser cache or open the task in an incognito window to force a fresh download.

---

> ⚠️ **Important:** Do **not** change folder or file names. Do not rename variables. Do not move files after decompressing the repository. The online version relies on exact paths and identifiers; any deviation can cause crashes.

---------------------------------------

## TECHNICAL DETAILS

The decompressed repository includes:

- `MBRT_online.psyexp` — main PsychoPy experiment file
- `Language_localiser.xlsx` — language configuration file
- `data-prep.R` — R script that reads all downloaded `.csv` files automatically, generates a `data.rdata` file, and stores it in the `data` folder. `data.rdata` contains MBRT testblock data in long format and demographic / summary data in wide format.

**Folder `mbrt_files`:**
- `Messages.xlsx`including messages for demographic data, instructions etc.
- excel files and folder `conditions_filtered` including the trials of the practice and test block for different experiment settings

**Folder `mbrt_images`:**
- stimulus and instruction images

**Folder `data`:**
- storage location for downloaded data

---------------------------------------
## EXPERIMENT SETTINGS (parameters to choose)

In the default configuration, participants can select their `language` upon starting the experiment. This is configured via **Experiment Settings → Experiment info → `language`** (see below for more information).  
`response_mode`, `n_angles`, `body_views`, `limbs`, `n_reps`    and `feedback` are experimenter-defined defaults set in code.

### Available Parameters
| Variable | Options | Description |
| :--- | :--- | :--- |
| `response_mode` | • **Both hands** (Default)<br>• Left hand<br>• Right hand | Determines the required input method. |
| `n_angles` | • **6** (0, 45, 135, 180, 225, 315) (Default)<br>• 4 (increments of 90)<br>• 6 (increments of 60)<br>• 8 (increments of 45)<br>• 12 (increments of 30) | Sets the number and type of rotation angles (in °) presented. |
| `body_views` | • **Front and Back** (Default)<br>• Front<br>• Back | Determines which body orientations are shown. |
| `limbs` | • **Arms and Legs** (Default)<br>• Arms<br>• Legs | Determines which limbs are rotated. |
| `n_reps` | • 1 <br>• **4** (Default) <br>• 8<br>• 12 | The number of times each unique stimulus is repeated. |
| `feedback` | • 0.3<br>• 0.5<br>• 0.8<br>• 1<br>• **No feedback in testblock(s)** (Default) | Duration of feedback (in seconds) per trial in the test blocks. |
| `language_localiser`| • **English** (Default)<br>• German | Sets the default language for the experiment. |

### Setting default values (code-based)

Defaults are controlled in the experiment code.

1. Open the corresponding code component in the corresponding settings routine
- `language`: `update_language_code` in `load_lg` routine
- `n_reps`: `n_reps_settings` in `exp_settings` routine
- `feedback`: `feedback_settings` in `exp_settings` routine
- `n_angles` , `body_views`, `limbs`: `conditions_settings` in `exp_settings` routine
2. Set your default value
3. Comment out the lines that overwrite the default with dialog input

This forces the experiment to use your hard-coded defaults.

#### Disable language selection

To hard-code a default language:

1. Experiment Settings → Basic → remove `language` entry
2. Open `load_language` routine
3. Code component `update_language_code`
4. Set default in **Begin experiment**
5. Comment out lines 2–3 in **Begin routine**


### Disable demographic questions

The experiment includes Age, Gender, and Handedness questions by default. These support normative data collection.

If you do not want to collect demographics:

1. Click `demographics` routine
2. Open **Routine settings**
3. In **Testing** tab → click **Disable Routine**

#### Saving and exporting

1. Save experiment
2. Sync via Pavlovia
3. Test via **Run on Pavlovia**
4. Distribute link

---------------------------------------
## PARTICIPANT WORKFLOW:

1.  **Settings selection:** Participants select language (optional)
2.  **Demographics:** Participants complete a basic form (Age, Gender, Handedness).
3.  **Instructions:** Detailed explanation of the task and assignment of response keys.
4.  **Practice Block:** A short series of trials (0 rotation) with feedback to familiarize participants with the key mapping.
5.  **Test Blocks:** The main experimental trials; for _n_reps_ > 1, divided into 4 blocks with breaks in between.
6.  **Completion:** Final "Goodbye" screen.

#### MBRT trial procedure
The sequence of a single trial is as follows:
1.  **Fixation dot:** Presented for 1000 ms.
2.  **Stimulus presentation:** Stays on screen until a keypress is recorded.
3.  **Feedback:** (Conditional) If enabled, feedback is shown for the selected duration.  
    *→ Automatic advance to the next trial.*

---------------------------------------

## OUTPUT
For online runs, data is stored on the selected server/host and can be downloaded from the project’s interface. The output is typically downloaded as one `.csv` file per participant/run.

Store these `.csv` files in the dedicated `data` folder located inside the unzipped repository. The provided `data-prep.R` script is designed to read all `.csv` files in this folder, extract relevant observations from the MBRT test block, and save the processed data as `data.rdata` in the `data` folder.

**To run the data preparation**, open `data-prep.R` and **source** the script.

The script will generate `data.rdata`, which contains two dataframes: `data_long_tbl` (trial-level MBRT test data) and `data_wide` (demographics and summary data).

> **Note:** This script relies on the standard PsychoPy/Pavlovia output structure. It expects a participant ID column (`participant` or `subject_nr`) and standard MBRT response columns`. If modifications were made beyond the configurable experiment settings, the code may need adaptation. Raw data should always be inspected and cleaned of outliers or errors prior to statistical analysis.

### Variable Documentation

#### 1. Testblock Trials Data (`data_long_tbl`)
*Contains one row per trial (filtered to test blocks).*

| Variable Name | Type | Description |
| :--- | :--- | :--- |
| `subject_nr` | factor | Participant ID. |
| `phase` | character | Experiment phase (e.g., "MBRT_testblock"). |
| `n_testbl` | integer | Test block index (1-4 if >1 repetitions selected). |
| `n_trial` | integer | Trial index (within the test phase). |
| `mbrt_correct` | integer | Correctness flag (1 = correct, 0 = incorrect). |
| `solution` | character | Correct response code for the trial (e.g., "s", "g", "l", "h"). |
| `mbrt_angle` | numeric | Stimulus rotation (degrees). |
| `mbrt_limb` | factor | Limb shown (e.g., "arm", "leg"). |
| `mbrt_side` | factor | Laterality ("left", "right"). |
| `mbrt_view` | factor | View ("front", "back"). |
| `mbrt_rt` | numeric | Response time in milliseconds (ms). |
| `trial_response` | character | Key pressed / response code (participant response). |

#### 2. Demographic Data (`data_wide`)
*Contains one row per subject (if demographics were enabled).*

| Variable Name | Type | Description |
| :--- | :--- | :--- |
| `subject_nr` | character | Participant ID. |
| `age` | integer | Participant age in years. |
| `gender` | integer | Participant gender coded as integer (female = 1, male = 2, transgender = 3, nonbinary = 4, other = 5, none = 6). |
| `handedness` | integer | Participant handedness/laterality coded as integer (left = 1, ambidextrous = 2, right = 3). |

---------------------------------------

PsychoPy version updates may require adjustments.  Developers are not responsible for adapting the task to every use case.  
Before collecting data, always test the experiment and check the data output.
Contributions are welcome.

---------------------------------------

## REFERENCE

Please cite [Czilczer et al. (2025)](https://osf.io/9xjfb) when using this resource.


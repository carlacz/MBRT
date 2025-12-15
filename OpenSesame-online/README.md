# MENTAL BODY ROTATION TASK (MBRT)

**Author:** Carla Czilczer, 12/12/2025  
**Software used:** OpenSesame 4.0.2  
**Experiment Type:** Online  
**Languages supported:** English (EN) = default, German (DE), Spanish (ES), French (FR). Further languages can be added, which requires simple changes in the code and updating the `.csv` files (see [language localization](#LANGUAGE-LOCALIZATION)). 

---------------------------------------
## GENERAL INSTRUCTIONS:

This experiment is built using [OpenSesame](osdoc.cogsci.nl). To run this experiment online, it utilizes the [OSWeb](https://osdoc.cogsci.nl/4.1/manual/osweb/osweb/) backend.  
If you are unfamiliar with OpenSesame, please refer to the [documentation](osdoc.cogsci.nl) on their website. This README specifically details the structure and customization of this MBRT implementation.  

---------------------------------------
## SETUP INSTRUCTIONS

To edit or run this this task locally, you need to have **OpenSesame** installed.  
To run the task online, you will likely need a [JATOS server]( https://www.jatos.org/). At the time of writing, [MindProbe](https://mindprobe.eu/) serves as a JATOS server free of charge.  
A script for data preparation in [R](https://www.r-project.org/) is provided.  

**Step-by-step instructions:**  
1.  **Download** and unzip the repository to a dedicated folder.
2.  Log in to your JATOS server (e.g., [JATOS sign-in in Mindprobe](https://jatos.mindprobe.eu/jatos/signin)), click ”**Import Study**”, and select the `.jzip` file (this is the experiment file).
3.  Name and click on the study to **open the dashboard**.
4.  Click on “Study Links”, **choose** your preferred study link type (e.g., Personal Single Link, General Multiple Link, MTurk), click on the “Study Link” button next to it and **copy the URL**.
5.  **Distribute** the generated link(s) to your participants. They run the task directly in their web browser.
6.  To **export data**, navigate in JATOS to “Results” ➝ “Export Results”. Select “Data only” ➝ “Plain Text” and save the file into the `data` folder located inside the unzipped repository.
7.  **Process the data** using the provided `.R` script.

---------------------------------------
## LANGUAGE LOCALIZATION

This experiment uses external `.csv` files to manage text and translations. This makes adding new languages relatively easy, but strict formatting rules apply.

**How it works:** Within the experiment, either a default language can be configured, or participants can select their preferred language at the start (for both, please see [experiment settings](#EXPERIMENT-SETTINGS) below, otherwise, the default “English” is applied). The experiment uses the corresponding _ISO_code_ (e.g., "EN", "DE") to retrieve the corresponding text from columns in the external `.csv` files (e.g., `Instructions.csv`, `Block_messages.csv`).

**Adding a new language:**
For more information, see this [Language Localisation Demo]( https://github.com/carlacz/OpenSesame_Language-Localisation-Demo/edit/main/Language_localiser_online/README.md)
### 1. Open the relevant `.csv` files
- `Language_localiser.csv`
- `Demographics.csv`
- `Messages.csv`
- `Instructions.csv`
- `Block_messages.csv`
### 2. Extend `language_localiser-semicolon.csv` by adding a new row  
```
language;ISO_code
English;EN
Spanish;ES
German;DE
French;FR
```

Add your new language (e.g., Italian) by inserting the _language_ and _ISO_code_ in a **new row**:
```
language;ISO_code
English;EN
Spanish;ES
German;DE
French;FR
Italian;IT
```
### 3. Extend the files `Demographics.csv`, `Messages.csv`,`Instructions.csv`, `Block_messages.csv` by adding a new column
Example: `Messages.csv`
```
message;EN;ES;DE;FR
welcome_msg;Welcome to the experiment!;Bienvenido/a al experimento!;Willkommen zum Experiment!;Bienvenue dans l'expérience !
adv_msg;Press SPACE to continue;Presiona ESPACIO para continuar;Drücken Sie die Leertaste um fortzufahren;Appuyez sur ESPACE pour continuer
bye_msg;You have finished the experiment;Has terminado el experimento;Sie haben das Experiment beendet;Vous avez terminé l'expérience
```

Add a **new column** using the _ISO_code_ (`IT`), and enter translations at the end of each row:
```
message;EN;ES;DE;FR;IT
welcome_msg;Welcome to the experiment!;Bienvenido/a al experimento!;Willkommen zum Experiment!;Bienvenue dans l'expérience !;Benvenuti all'esperimento!
adv_msg;Press SPACE to continue;Presiona ESPACIO para continuar;Drücken Sie die Leertaste um fortzufahren;Appuyez sur ESPACE pour continuer;Premere lo SPAZIO per continuare
bye_msg;You have finished the experiment;Has terminado el experimento;Sie haben das Experiment beendet;Vous avez terminé l'expérience;Avete terminato l'esperimento
```

⚠️Do this for each of the listed `.csv` files!


### 4. Update the experiment
1. Open the experiment
2. Go to the **overview tab**
3. In the `experiment_sequence`, click on `language_localiser`
4. In the window with listed language names, add your new language name (e.g., `Italian`) in a new row — it must exactly match the entry in your `language_localiser.csv`

### 5. Reload the updated `.csv` files into the file pool
1. Open the file pool (folder icon with image) 
2. Click the **green plus** button
3. Select the updated `.csv` files you updated and upload them — they will replace the old ones
4. Save the experiment

### 6. Export experiment as `.jzip`
In OpenSesame, open the OSWeb extension (“Tools” in the top bar → “OSWeb and JATOS control panel”), and click on “Export to JATOS archive”. This saves a new `.jzip` file that you then upload to your JATOS server.  

#####⚠️ CRITICAL: TEXT FORMATTING IN CSV FILES
When editing the `.csv` files to add translations or change text, you **MUST use HTML tags** to format text directly. **DO NOT** use Enter for a linebreak.   

Common HTML tags used for this experiment:
* `<b>Text</b>` : Makes text **bold**.
* `<br>` : Inserts a line break (new line).
* `<i>Text</i>` : Makes text *italic*.
* `<span style='color:red'>Text</span>` : Changes text color.  
If you do not use HTML tags, the formatting will not appear in the online experiment.  
When adding a new language, you must manually insert line breaks using `<br>` within the cell. Otherwise, longer instructions will be truncated. **Do not use the "Enter" key**, as this causes rendering errors and text misalignment during the experiment.  

#####⚠️ CRITICAL: NAMES OF FOLDERS, FILES AND VARIABLES
You must **MUST NOT** change the names of the folders or files, as this will cause the experiment to crash. Additionally, do not change any variable names; the experiment logic depends on these specific identifiers, and renaming them requires updating the underlying code. Do not move files after decompressing the repository. Any deviation from the original file structure or naming will lead to a crash.

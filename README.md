# Mental Body Rotation Task (MBRT)

Available in **English**, **German**, **Spanish**, **French** (see below to implement the task in other languages).

The MBRT is a behavioural paradigm aiming to assess the ability to manipulate movement imagery. If you are interested in assessing Movement Imagery ability, visit the [Movement Imagery Ability Platform](movementimageryability.github.io) for an overview of open-source behavioural tasks.

The task was adapted from classical mental rotation paradigms [Shepard & Metzler, (1988)](https://doi.org/10.1037/0096-1523.14.1.3) to emphasize body-centered transformations and motor-cognitive integration ([Dahm et al., 2022](https://doi.org/10.3390/brainsci12111500); [Steggmann et al., 2011](https://doi.org/10.1016/j.bandc.2011.02.013)). This repository contains the materials for an open-source (and user-friendly) version of the MBRT for local and online use, based on [Dahm et al. (2022)](https://doi.org/10.3390/brainsci12111500).
The most updated versions can be found in this repository.

Subsequent updates in native software ([PsychoPy](https://www.psychopy.org/index.html) and [OpenSesame](https://osdoc.cogsci.nl/)) may need adjustments. As developers, we are not responsible for implementing these in every use case.

An example of the setup is shown below.
![MBRT-demo](MBRT-demo.gif)

## Repository information
The repository has two main folders, which contain PsychoPy experiments (.psyexp) and associated files to be able to run them locally or online. Please consult the Readme files for each version before using them (local and online versions are NOT equivalent in terms of configuration). The Readme files contain extensive documentation on the most relevant task settings and detailed information to allow the user further customization.

The versions provided in this repository allow flexibility in terms of key experiment parameters of the MBRT:
- angles of rotation
- body views
- limbs
- types of response
- trial-to-trial feedback
- number of repetitions

The optimal protocol is at the user's discretion, but sensible defaults have been implemented.

## Language expansion
If you want to contribute to this repository by providing a language translation, or want to run the task in your own language, expansions can be done relatively easily thanks to the implementation of language localisations (please read each README to understand how to implement these). You can also see this demo showing how to implement a language localisation in [PsychoPy](https://github.com/mmorenoverdu/language_localisation_demo) and [OpenSesame](https://github.com/carlacz/OpenSesame_Language-Localisation-Demo) with virtually no code.

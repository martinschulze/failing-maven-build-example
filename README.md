# failing-maven-build-example
<s>This maven build fails. Asking for help.</s>
Keep this for my future self for reference.

## This project builds within eclipse
To verify this fact:
* Import the projects from git (including nested projects)
* In the main project, run the file 'Fowler.xtext' as 'Generate Xtext Artifacts'
* Clean and build all projects
This shows that both external and internal dependencies are resolved correctly.

## This project does <s>not</s> build with maven
The problem has been the missing @Genmodel annotation.


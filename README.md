# matlab-notebook
Dynamic execution of MATLAB models and collection of results.
The idea here is to execute MATLAB functions from Java.

## Installation

### MathWorks MATLAB Java Engine

1. Locate MATLAB installation directory, *<matlab_root>*:
   - On MacOS, this is `/Applications/MATLAB_R2021a.app`
   - On CentOS, CSU Lab machines `/s/parsons/l/sys/matlab`
2. Add MATLAB architecture to system environment variable:
   - Documentation for this step: https://www.mathworks.com/help/matlab/matlab_external/setup-environment.html
   - On MacOS, this is `<matlab_root>/bin/maci64`
      - Add `export DYLD_LIBRARY_PATH="/Applications/MATLAB_R2021a.app/bin/maci64"` to .zshrc or .bashrc
   - On CentOS, CSU Lab machines `<matlab_root>/bin/glnxa64:<matlab_root>/sys/os/glnxa64`
      - Add `export LD_LIBRARY_PATH="/s/parsons/l/sys/matlab/bin/glnxa64:/s/parsons/l/sys/matlab/sys/os/glnxa64"` to .zshrc or .bashrc
4. Locate Java engine jars within:
   - `<matlab_root>/java/jar`
5. Add required jars to Gradle/Maven dependencies:
   - Example for Gradle on MacOS:

```groovy
dependencies {
   implementation files('/Applications/MATLAB_R2021a.app/java/jar/engine.jar')
   implementation files('/Applications/MATLAB_R2021a.app/java/jar/javaenginecore.jar')
   implementation files('/Applications/MATLAB_R2021a.app/java/jar/matlab.jar')
}
```

Helpful documentation:
- [Executing MATLAB from Java](https://www.mathworks.com/help/matlab/matlab_external/execute-matlab-functions-from-java.html)
- [Executing a user-defined MATLAB script from Java](https://www.mathworks.com/matlabcentral/answers/355278-calling-user-defined-script-from-java)
- [Writing a MATLAB matrix to CSV file](https://www.mathworks.com/matlabcentral/answers/281156-how-can-i-export-a-matrix-as-a-csv-file)
import com.mathworks.engine.*;
import com.mathworks.javaenginecore.*;

import java.util.concurrent.ExecutionException;

public class Main {

    public static void main(String[] programArgs) {
        System.out.println("Hello world!");
        try {
            MatlabEngine matlabEngine = MatlabEngine.startMatlab();

            matlabEngine.eval("cd matlab_testing/");
            matlabEngine.eval("test()");
            matlabEngine.close();

        } catch(EngineException e) {
            e.printStackTrace();
        } catch(InterruptedException e) {
            e.printStackTrace();
        } catch(ExecutionException e) {
            e.printStackTrace();
        }


    }


}

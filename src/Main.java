import com.mathworks.engine.*;
import com.mathworks.javaenginecore.*;

import java.util.concurrent.ExecutionException;

public class Main {


    public static void main(String[] programArgs) {
        System.out.println("Hello world!");
        try {
            MatlabEngine eng = MatlabEngine.startMatlab();

            double[] a = {2.0 ,4.0, 6.0};
            double[] roots = eng.feval("sqrt", a);
            for (double e: roots) {
                System.out.println(e);
            }

            eng.close();
        } catch(EngineException e) {
            e.printStackTrace();
        } catch(InterruptedException e) {
            e.printStackTrace();
        } catch(ExecutionException e) {
            e.printStackTrace();
        }


    }


}

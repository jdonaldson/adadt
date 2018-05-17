package ;
import  tink.testrunner.*;
import  tink.unit.*;

class RunTests {

  static function main() {
    Runner.run(TestBatch.make([
          new ApiTest()
    ])).handle(Runner.exit);
    travix.Logger.println('it works');
    travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
  }


}

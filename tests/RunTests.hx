package ;
import  tink.testrunner.*;
import  tink.unit.*;

class RunTests {

  static function main() {
    Runner.run(TestBatch.make([
          new ApiTest()
    ])).handle(Runner.exit);
    travix.Logger.exit(0);
  }


}

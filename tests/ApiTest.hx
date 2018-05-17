import  tink.testrunner.*;
import adadt.ADADT;

class ApiTest {
  public function new(){}
  static function fn(x: String, y : String) return x > y ? -1 : x < y ? 1 : 0;


  @:describe('basic ADADT test')
  public function testADADT() {
    var dummy : ADADT<TestAdtApi> = TestAdtApi_ADT.Bar(0);
    var enums = Type.getEnumConstructs(TestAdtApi_ADT);
    enums.sort(fn);
    var res = enums.join(",");
    return new Assertion(res == "Foo,Bing,Bar", res);
  }

  @:describe('builder-style test')
  public function testBuilder() {
    var enums = Type.getEnumConstructs(TestBuilderResult);
    enums.sort(fn);
    var res = enums.join(",");
    return new Assertion(res == "Foo,Bing,Bar,Additional", res);
  }

}

package adadt;

import haxe.macro.*;
import haxe.macro.Expr;
using haxe.macro.TypeTools;

class Build {


  /**
    Constructs an ADT from the `api` argument expression.
    Use in @:build/@:autoBuild functions.
  **/
  public static function build(api : Expr) : Array<Field> {
    var enm = Context.getLocalType().getEnum();
    Utils.checkTopLevel(enm);

    var type = Context.getLocalType();

    switch(type){
      case TEnum(_) : null;
      default : Context.error("ADADT builder requires an enum", Utils.pos());
    }

    var api_class = Utils.getClass(api);

    var fields = api_class.fields.get();
    var enum_fields = [];

    for (f in fields){
      if (f.name == "new" || !f.isPublic) continue;

      var t = Context.followWithAbstracts(f.type);
      var ret = switch(t){
        case TFun(args,ret) : ret;
        default : f.type;
      };

      enum_fields.push({
        name : Utils.titleCase(f.name),
        pos : api.pos,
        kind : FFun({
          args : [{
            name : "result",
            type : ret.toComplexType()
          }],
          expr : null,
          ret : null
        })
      });
    }

    return enum_fields.concat(Context.getBuildFields());
  }

  /**
    Creates an ADT from the corresponding type parameter.
    Use in @:genericBuild functions.
  **/
  public static function generic() {
    var states = [];
    var type = Context.getLocalType();
    switch (type) {
      case TInst(_, [TInst(t1,[])]) : {
        var cls = t1.get();
        var clsfields = cls.fields.get();

        var fields : Array<Field> = [] ;

        for (f in clsfields) {
          if (f.name == "new" || !f.isPublic) continue;
          var t = Context.followWithAbstracts(f.type);
          var ret_type = switch(t){
            case TFun(args, ret) : ret;
            default : f.type;
          }
          var field = {
            name : Utils.titleCase(f.name),
            pos : Context.currentPos(),
            kind : FFun({
              args : [{
                name : "result",
                type : ret_type.toComplexType()
              }],
              ret : null,
              expr : null
            })
          }
          fields.push(field);
        };

        var pack = cls.pack.length > 0 ? cls.pack.join(".") + "." : "";
        var clsname = cls.name + "_ADT";
        var name = pack + clsname;

        try {
          return  Context.getType(name);
        } catch (e : Dynamic) {
          Context.defineType({
            fields : fields,
            kind : TDEnum,
            name : clsname,
            pack : cls.pack,
            pos : Context.currentPos()
          });
          return Context.getType(name);
        }
      }
      default : {
        Context.error("Unexpected Type", Context.currentPos());
        return null;
      }

    }
  }
}

/**
  Simple helper library (find another repo for these)
**/
private class Utils {
  public function new(){}
  public static function getClass(arg : Expr) {
    var type = getType(arg);
    var cls = type.getClass();
    if (cls == null){
      Context.error('Class ${type.getName()} does not exist', pos());
    }
    return cls;
  }
  public static function checkTopLevel(cls: {module : String, name : String}){
    var modules = cls.module.split(".");
    if (cls.name != modules[modules.length-1]){
      Context.error("Classes and enums built by this library must be top level in their module.  Please move this declaration to a new file.", pos());
    }
  }
  public static function pos() : Position {
    return Context.currentPos();
  }
  public static function getType(arg : Expr) {
    var class_name = switch(arg){
      case {expr : EConst(CIdent(str) | CString(str))} : str;
      default : {
        Context.error("Argument should be a Class name", pos());
        null;
      }
    }
    return Context.getType(class_name);
  }
  public inline static function titleCase(name : String) : String{
    return name.charAt(0).toUpperCase() + name.substr(1);
  }
}

import haxe.macro.*;
import haxe.macro.Expr;
using haxe.macro.TypeTools;
import golgi.builder.Initializer.titleCase;


@:genericBuild(ADADTbuilder.build())
class ADADT<T> { }

private class ADADTbuilder {
  static public function build() : haxe.macro.Type {
    var states = [];
    var constructs = new Map<String, Type.EnumField>();
    var type = Context.getLocalType();
    switch (type) {
      case TInst(_, [TInst(t1,[])]) : {
        var cls = t1.get();
        var meta = cls.meta;
        var fields = cls.fields.get();
        var index = 0;
        for (f in cls.fields.get()){
          if (!f.isPublic) continue;
          var res = switch(Context.follow(f.type)){
            case TFun(args, ret) : { name : f.name, type : ret};
            case TInst(t,_) : { name : f.name, type : f.type};
            default : continue;
          }
          constructs.set(res.name, {
            index : index++,
            meta : {
              add : function(name  : String, params : Array<Expr>, pos : Position) {},
              extract : function(name : String) return [],
              remove : function(name : String) {},
              has : function(name : String) return false,
              get : function() return null
            },
            type : res.type,
            pos : Context.currentPos(),
            params : [],
            name : type.getName(),
            doc : null,
          });
        }
        var names = [for (n in constructs.keys()) n];
        names.sort((x,y)->(x > y) ? -1 : (x < y) ?  1 : 0);

        var fields : Array<Field> = [] ;
        for (k in constructs.keys()) {
          var field = {
            name : titleCase(k),
            pos : Context.currentPos(),
            kind : FFun({
              args : [{
                name : "result",
                type : constructs.get(k).type.toComplexType()
              }],
              ret : null,
              expr : null
            })
          }
          fields.push(field);
        };

        var name = cls.pack.length > 0 ? cls.pack.join(".") + "." : "";
        name += cls.name + "ADADT";

        try {
          return Context.getType(name);
        } catch (e : Dynamic) {
          Context.defineType({
            fields : fields,
            kind : TDEnum,
            name : cls.name  + "ADADT",
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

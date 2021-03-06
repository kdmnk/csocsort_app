import 'package:flutter/material.dart';
import 'history.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'shopping.dart';
import 'config.dart';
import 'new_expense.dart';

class ShoppingRoute extends StatefulWidget {
  final ShoppingData data;
  ShoppingRoute({@required this.data});
  @override
  _ShoppingRouteState createState() => _ShoppingRouteState();
}

class _ShoppingRouteState extends State<ShoppingRoute> {

  @override
  Widget build(BuildContext context) {
    String title='';
    if(widget.data.item==''){
      title='Nincs megjegyzés';
    }else{
      title=widget.data.item[0].toUpperCase()+widget.data.item.substring(1);
    }
    return Scaffold(
      appBar: AppBar(title: Text(title),),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[
            ShoppingAllInfo(widget.data),
            History()
          ],
        ),
      ),
    );
  }
}

class ShoppingAllInfo extends StatefulWidget {
  final ShoppingData data;
  ShoppingAllInfo(this.data);
  @override
  _ShoppingAllInfoState createState() => _ShoppingAllInfoState();
}

class _ShoppingAllInfoState extends State<ShoppingAllInfo> {
  Future<bool> _deleteShopping(int id) async {
    try{
      Map<String, dynamic> map = {
        "type":'delete',
        "id":id
      };

      String encoded = json.encode(map);
      http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/list/', body: encoded);


      return response.statusCode==200;
    }catch(_){
      throw 'Hiba';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.data.user, style: Theme.of(context).textTheme.body2,)),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: <Widget>[
                  Icon(Icons.shopping_basket, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.data.quantity+' '+widget.data.item, style: Theme.of(context).textTheme.body2)),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: <Widget>[
                  Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary,),
                  Text(' - '),
                  Flexible(child: Text(DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.date), style: Theme.of(context).textTheme.body2)),
                ],
              ),
              SizedBox(height: 10,),
              Visibility(
                visible: widget.data.user==currentUser,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
//                          FlatButton.icon(
//
//                            onPressed: (){
//                              showDialog(
//                                  context: context,
//                                  child: Dialog(
//                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                                    backgroundColor: Theme.of(context).colorScheme.onBackground,
//                                    child: Container(
//                                      padding: EdgeInsets.all(8),
//                                      child: Column(
//                                        crossAxisAlignment: CrossAxisAlignment.center,
//                                        mainAxisSize: MainAxisSize.min,
//                                        children: <Widget>[
//                                          Text('Szerkeszteni szeretnéd a tételt?', style: Theme.of(context).textTheme.title, textAlign: TextAlign.center,),
//                                          SizedBox(height: 15,),
//                                          Row(
//                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                            children: <Widget>[
//                                              RaisedButton(
//                                                  color: Theme.of(context).colorScheme.secondary,
//                                                  onPressed: (){
//                                                        Navigator.pop(context);
//                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense(type: ExpenseType.fromSavedExpense,
//                                                          expense: new SavedExpense(name: widget.data.fromUser,
//                                                              names: widget.data.toUser,
//                                                              amount: widget.data.amount,
//                                                              note: widget.data.note,
//                                                              iD: widget.data.transactionID
//                                                          ),
//                                                        )));
//                                                  },
//                                                  child: Text('Igen', style: Theme.of(context).textTheme.button)
//                                              ),
//                                              RaisedButton(
//                                                  color: Theme.of(context).colorScheme.secondary,
//                                                  onPressed: (){ Navigator.pop(context);},
//                                                  child: Text('Nem', style: Theme.of(context).textTheme.button)
//                                              )
//                                            ],
//                                          )
//                                        ],
//                                      ),
//                                    ),
//                                  )
//                              );
//                            },
//                            color: Theme.of(context).colorScheme.secondary,
//                            label: Text('Szerkesztés', style: Theme.of(context).textTheme.button,),
//                            icon: Icon(Icons.edit, color: Theme.of(context).textTheme.button.color),
//                          ),
                    FlatButton.icon(
                        onPressed: (){
                          showDialog(
                              context: context,
                              child: Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                backgroundColor: Theme.of(context).colorScheme.onBackground,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text('Törölni szeretnéd a tételt?', style: Theme.of(context).textTheme.title,),
                                      SizedBox(height: 15,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          RaisedButton(
                                              color: Theme.of(context).colorScheme.secondary,
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                Future<bool> success = _deleteShopping(widget.data.shoppingId);
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    child: Dialog(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                      backgroundColor: Colors.transparent,
                                                      elevation: 0,
                                                      child: FutureBuilder(
                                                        future: success,
                                                        builder: (context, snapshot){
                                                          if(snapshot.connectionState==ConnectionState.done){
                                                            if(snapshot.hasData && snapshot.data){
                                                              return Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Flexible(child: Text("A tételt sikeresen töröltük!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                                                  SizedBox(height: 15,),
                                                                  FlatButton.icon(
                                                                    icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                                                    onPressed: (){
                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context, 'deleted');
                                                                    },
                                                                    label: Text('Rendben', style: Theme.of(context).textTheme.button,),
                                                                    color: Theme.of(context).colorScheme.secondary,
                                                                  )
                                                                ],
                                                              );
                                                            }else{
                                                              return Container(
                                                                color: Colors.transparent ,
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Flexible(child: Text("Hiba történt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                                                    SizedBox(height: 15,),
                                                                    FlatButton.icon(
                                                                      icon: Icon(Icons.clear, color: Colors.white,),
                                                                      onPressed: (){
                                                                        Navigator.pop(context);
                                                                      },
                                                                      label: Text('Vissza', style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),),
                                                                      color: Colors.red,
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                          }
                                                          return Center(child: CircularProgressIndicator());

                                                        },
                                                      ),
                                                    )
                                                );
                                              },
                                              child: Text('Igen', style: Theme.of(context).textTheme.button)
                                          ),
                                          RaisedButton(
                                              color: Theme.of(context).colorScheme.secondary,
                                              onPressed: (){ Navigator.pop(context);},
                                              child: Text('Nem', style: Theme.of(context).textTheme.button)
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                          );
                        },
                        color: Theme.of(context).colorScheme.secondary,
                        label: Text('Törlés', style: Theme.of(context).textTheme.button,),
                        icon: Icon(Icons.cancel, color: Theme.of(context).textTheme.button.color)
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: widget.data.user!=currentUser,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton.icon(
                      onPressed: (){
                        Future<bool> success = _deleteShopping(widget.data.shoppingId);
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            child: Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: FutureBuilder(
                                future: success,
                                builder: (context, snapshot){
                                  if(snapshot.connectionState==ConnectionState.done){
                                    if(snapshot.hasData){
                                      if(snapshot.data){
                                        return Container(

                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Theme.of(context).cardTheme.color,),
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text('Fel szeretnéd számolni?', style: Theme.of(context).textTheme.title, textAlign: TextAlign.center,),
                                              SizedBox(height: 15,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  RaisedButton(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      onPressed: (){
                                                        Navigator.pop(context);
                                                        Navigator.pop(context, 'deleted');
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense(
                                                          type: ExpenseType.fromShopping, shoppingData: widget.data,
                                                        )));
                                                      },
                                                      child: Text('Igen', style: Theme.of(context).textTheme.button)
                                                  ),
                                                  RaisedButton(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      onPressed: (){
                                                        Navigator.pop(context);
                                                        Navigator.pop(context, 'deleted');
                                                      },
                                                      child: Text('Nem', style: Theme.of(context).textTheme.button)
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      }else{
                                        return Container(
                                          color: Colors.transparent ,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(child: Text("Hiba történt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                              SizedBox(height: 15,),
                                              FlatButton.icon(
                                                icon: Icon(Icons.clear, color: Colors.white,),
                                                onPressed: (){
                                                  Navigator.pop(context);
                                                },
                                                label: Text('Vissza', style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),),
                                                color: Colors.red,
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    }else{
                                      return Container(
                                        color: Colors.transparent ,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(child: Text("Hiba történt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                            SizedBox(height: 15,),
                                            FlatButton.icon(
                                              icon: Icon(Icons.clear, color: Colors.white,),
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              label: Text('Vissza', style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),),
                                              color: Colors.red,
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  }else{
                                    return Center(child: CircularProgressIndicator());
                                  }
                                },
                              ),
                            )
                        );
                      },
                      color: Theme.of(context).colorScheme.secondary,
                      label: Text('Megvettem', style: Theme.of(context).textTheme.button),
                      icon: Icon(Icons.check, color: Theme.of(context).textTheme.button.color),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}


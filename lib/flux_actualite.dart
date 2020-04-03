import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
class Flux extends StatefulWidget {
  @override
  _FluxState createState() => _FluxState();
}

class _FluxState extends State<Flux>  with SingleTickerProviderStateMixin{
  /*
  * VARIABLE
  * */
  static final url = "https://www.nouvelobs.com/coronavirus-de-wuhan/rss.xml";
  RssFeed _flux;
  String titre ;
  static const String messageDeChargementFlux = "Chargement en cour...";
  static const String messageErreurFlux = "Ereur de chargement";
  static const String messageErreurOuvertureFlux = "Impossible de charger la page";
  static const String placeholderImg = "assets/images/placeholder.jpg";
  GlobalKey<RefreshIndicatorState> _refresKey;




/*
* CHARGEMENT DU FLUX RSS
* */
  Future<RssFeed> chargerFlux() async {
    try{
      final client = http.Client();
      final response = await client.get(url);
      return RssFeed.parse(response.body);
    }catch(e){
      print(e);
    }
    return null;
  }

  miseAjourFlux(flux){
    setState(() {
      _flux = flux;
    });
  }

  //chargerger toute les données si le resultat n'est pas vide
  chargement() async{
    chargerFlux().then((result){
      if(result == null || result.toString().isEmpty ){
        return;
      }
      miseAjourFlux(result);

    });
  }

  titreDuFlux(titre){
    return Text(
      titre,
      style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500 ,color: Colors.white),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  sousTitreDuFlux(data){
    return Text(
      data,
      style: TextStyle(fontSize: 10,fontWeight:FontWeight.w500,color: Colors.white ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  miniature(imageUrl){
    return Padding(
      padding: EdgeInsets.only(left: 2),
      child: CachedNetworkImage(
        placeholder: (context,url)=>Image.asset(placeholderImg),
        imageUrl: imageUrl,
        height:50 ,
        width: 70,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      ),
    );
  }

  //URL LAUNCHER POUR VISUALISER L'article
Future<void> ouvrirFlux (String urlString) async{
    if(await canLaunch(urlString)){
      await launch(urlString,forceWebView: true,forceSafariVC: false,);
    }
}

//Todo: ameliorer cette card pour les news
  newsCard(String imageUrl,String url,String sousTitre,String titre){
    return Card(

      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(15)),
      margin: EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 10),
      color: Colors.white,

      child: Container(

        child: InkWell(
          onTap: () => ouvrirFlux(url),
          child: Stack(
            alignment: Alignment.bottomCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: CachedNetworkImage(

                  placeholder: (context, url) => Image.asset(placeholderImg),
                  imageUrl: imageUrl,
                  width: MediaQuery.of(context).size.width,
                  
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,end: Alignment.topCenter, colors: <Color>[
                        Colors.black87,
                    Color.fromRGBO(0, 0, 0, 0.2),
                    Colors.transparent

                  ],
                    stops: [
                      0.1,
                      0.8,
                      0.9
                    ]
                  ),
                ),
                child: Column(
                  children: <Widget>[


                    Container(
                      padding: EdgeInsets.all(10),
                      child: titreDuFlux(titre),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                      child: sousTitreDuFlux(sousTitre),

                    ),
                  ],
                ),
              ),
            ],
          ))));
  }
list(){
    return ListView.builder(
      itemCount: _flux.items.length,
        itemBuilder: (BuildContext context ,int index){
        var item = _flux.items[index];
        //return newsCard(item.enclosure.url,item.link);
        return newsCard(item.enclosure.url,item.link,item.description,item.title);
        });
  }

  body(){
    return       (_flux == null || _flux.items == null)?
    Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(messageDeChargementFlux),
        CircularProgressIndicator(),
      ],
    ))
        :
    RefreshIndicator(
      child: list(),
      onRefresh: ()=>chargement(),
      key: _refresKey,

    );
  }





  /*
  * INITIALISATION DE TOUTE LES DONNEES
  * */
  @override
  void initState() {
    chargement();
    _refresKey = GlobalKey<RefreshIndicatorState>();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(

      ),
      appBar:AppBar(
        title: Text("Actualite"),
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: body(),
    );
  }
}

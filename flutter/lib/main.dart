import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

void main() {
  runApp(BlackjackApp());
}
String baseurl="192.168.132.76:3500";
class BlackjackApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blackjack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlackjackApp2(),
    );
  }
}



class BlackjackApp2 extends StatelessWidget {
  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Start the countdown when the widget is built
    Future.delayed(Duration(milliseconds: 1500), () {
      // Navigate to another page after 3 seconds
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BlackjackApp1()),
      );
    });

    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/dsd.json'),
      ),
    );
  }
}



class BlackjackApp1 extends StatelessWidget {
  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.green,
            child: Column(
              children: [
                TextField(
                  controller: name,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BlackjackScreen(name: "udit")));
                    },
                    child: Text("go")),


              ],
            )

        )
    );
  }
}

class CardModel {
  final String rank;
  final String suit;
  int value;

  CardModel({required this.rank, required this.suit})
      : value = _calculateValue(rank);

  static int _calculateValue(String rank) {
    switch (rank) {
      case '2':
        return 2;
      case '3':
        return 3;
      case '4':
        return 4;
      case '5':
        return 5;
      case '6':
        return 6;
      case '7':
        return 7;
      case '8':
        return 8;
      case '9':
        return 9;
      case '10':
        return 10;
      case 'J':
        return 10;
      case 'Q':
        return 10;
      case 'K':
        return 10;
      case 'A':
        return 1; // Default value for ace is 1
      default:
        return 0;
    }
  }
}

class BlackjackScreen extends StatefulWidget {
  final String name;
  BlackjackScreen({required this.name});

  @override
  _BlackjackScreenState createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  TextEditingController betamount = TextEditingController();
  List<CardModel> deck = [];
  List<CardModel> playerHand = [];
  List<CardModel> dealerHand = [];
  List<String> matchResults = []; // List to store match results
  bool isPlaying = false;
  String errorMessage = '';
  int playerSum = 0;
  int dealerSum = 0;
  int balance = 0; // Starting balance
  int bet = 0;
  int dispbet=0;
  bool isBetSelected = false;
  bool showDealerSecondCard =
  false; // Variable to track visibility of the second card of the dealer
  String username = ""; // Placeholder username

  int totalWins = 0;
  int totalLosses = 0;
  int totalTies = 0;

  @override
  void initState() {
    super.initState();
    initializeDeck();
    shuffleDeck();
    fetchUserBalance(widget.name);
    fetchUserStats(widget.name);
  }

  void initializeDeck() {
    List<String> suits = ['1', '2', '3', '4'];
    List<String> ranks = [
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
      'A'
    ];

    for (String suit in suits) {
      for (String rank in ranks) {
        deck.add(CardModel(rank: rank, suit: suit));
      }
    }
  }

  void shuffleDeck() {
    deck.shuffle();
  }

  void fetchUserBalance(String username) async {
    final response = await http.get(
        Uri.parse('http://$baseurl/user/$username/balance'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        balance = jsonData['balance'];
      });
    } else {
      print('Failed to fetch user balance: ${response.reasonPhrase}');
    }
  }

  void fetchUserStats(String username) async {
    final response = await http.get(
        Uri.parse('http://$baseurl/users/$username/results'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        totalWins = jsonData['wins'];
        totalLosses = jsonData['losses'];
        totalTies = jsonData['ties'];
      });
    } else {
      print('Failed to fetch user stats: ${response.reasonPhrase}');
    }
  }

  void dealInitialCards() {
    if (deck.length >= 10) {
      playerHand = [deck.removeLast(), deck.removeLast()];
      dealerHand = [deck.removeLast(), deck.removeLast()];
      playerSum = _calculateSum(playerHand);
      dealerSum = _calculateSum(dealerHand);
      balance -= bet; // Deduct the bet from the balance
    } else {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        // prevent dismissing the dialog by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Shuffling Cards'),
            content: CircularProgressIndicator(),
          );
        },
      );

      // Shuffle the deck again to get all 52 cards
      initializeDeck();
      shuffleDeck();

      // Hide loading indicator
      Navigator.pop(context);

      // Deal initial cards again
      playerHand = [deck.removeLast(), deck.removeLast()];
      dealerHand = [deck.removeLast(), deck.removeLast()];
      playerSum = _calculateSum(playerHand);
      dealerSum = _calculateSum(dealerHand);
      balance -= bet; // Deduct the bet from the balance
    }
  }


  void hitPlayer() {
    setState(() {
      playerHand.add(deck.removeLast());
      playerSum = _calculateSum(playerHand);
      if (playerSum >= 21) {
        _checkWinner(playerSum, dealerSum);
      }
    });
  }

  void standPlayer() {
    while (dealerSum < 17) {
      dealerHand.add(deck.removeLast());
      dealerSum = _calculateSum(dealerHand);
    }
    setState(() {
      showDealerSecondCard = true; // Reveal the second card of the dealer
    });

    _checkWinner(playerSum, dealerSum);
  }

  void hitDealer() {
    setState(() {
      if (dealerSum < 18) {
        dealerHand.add(deck.removeLast());
      }
      dealerSum = _calculateSum(dealerHand);
      _checkWinner(playerSum, dealerSum);
    });
  }

  void _checkWinner(int playerSum, int dealerSum) async {
    String result = '';
    String animationAsset = '';

    if (playerSum > 21) {
      result = 'Player Busts! Dealer Wins!';
      matchResults.add('Loss $bet -$bet');
      totalLosses++;
      await sendMatchDetails(widget.name, "Loss", bet, -bet);
      animationAsset = 'assets/loss.json'; // Use loss animation
    } else if (dealerSum > 21) {
      result = 'Player Wins with Blackjack!';
      balance += bet * 2;
      matchResults.add('Win $bet ${bet * 2}');
      totalWins++;
      await sendMatchDetails(widget.name, "Won", bet, bet * 2);
      animationAsset = 'assets/won.json'; // Use win animation
    } else if (playerSum < 21) {
      if (playerSum > dealerSum) {
        result = 'Player Wins!';
        balance += bet * 2;
        matchResults.add('Win $bet ${bet * 2}');
        totalWins++;
        await sendMatchDetails(widget.name, "Won", bet, bet * 2);
        animationAsset = 'assets/won.json'; // Use win animation
      } else if (playerSum < dealerSum) {
        result = 'Dealer Wins!';
        matchResults.add('Loss $bet -$bet');
        totalLosses++;
        await sendMatchDetails(widget.name, "Loss", bet, -bet);
        animationAsset = 'assets/loss.json'; // Use loss animation
      } else {
        result = 'Tie!';
        balance += bet;
        matchResults.add('Tie $bet $bet');
        totalTies++;
        await sendMatchDetails(widget.name, "Tie", bet, bet);
        // For tie, you can choose to show a different animation or keep it the same as win
        animationAsset = 'assets/won.json'; // Use win animation for tie as an example
      }
    } else if (playerSum == 21) {
      result = 'Player Wins with Blackjack!';
      balance += bet * 2;
      matchResults.add('Win $bet ${bet * 2}');
      totalWins++;
      await sendMatchDetails(widget.name, "Won", bet, bet * 2);
      animationAsset = 'assets/won.json'; // Use win animation
    }

    // Update user stats in the database

    showDialog(
      context: context,
      barrierDismissible: true,
      // allow dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            // Dismiss the dialog
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background
              Container(
                color: Colors.black.withOpacity(
                    0.5), // Adjust opacity as needed
              ),
              // Lottie animation
              Center(
                child: Lottie.asset(
                  animationAsset,
                  // Use the determined animation asset
                  width: 200, // Adjust animation width as needed
                  height: 200, // Adjust animation height as needed
                ),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(Duration(milliseconds: 2500));

    // Dismiss the dialog
    Navigator.pop(context);

    setState(() {
      playerHand.clear();
      dealerHand.clear();
      isPlaying = false;
      playerSum = 0;
      dealerSum = 0;
      bet =0;
      showDealerSecondCard = false;
    });

    updateUserStats(widget.name, totalWins, totalLosses, totalTies);

    // Update user balance in the database
    updateUserBalance(widget.name, balance);
  }


  Future<void> updateUserBalance(String username, int balance) async {
    final response = await http.put(
      Uri.parse('http://$baseurl/user/$username/balance'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'balance': balance,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to update user balance: ${response.reasonPhrase}');
    }
  }

  void _showInsufficientBalanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Insufficient Balance'),
          content: Text('You don\'t have enough balance to place this bet.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  bet=0;
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendMatchDetails(
      String username, String iesResult, int betAmount, int amountWon) async {
    final url = Uri.parse('http://192.168.132.76:3500/api/results');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'username': username,
      'iesResult': iesResult,
      'amount': betAmount,
      'amountWon': amountWon,
    });

    try {
      final response =
      await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Match details sent successfully');
      } else {
        print('Failed to send match details: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending match details: $e');
    }
  }

  void _playBlackjack(int bet ) {
    if (balance < bet) {
      setState(() {
        errorMessage = 'Insufficient balance!'; // Set the error message
      });
      _showInsufficientBalanceDialog();
    } else {
      setState(() {
        errorMessage = ''; // Clear the error message
        isPlaying = true;
        dealInitialCards();
      });
    }

  }

  Widget _buildCardWidget(CardModel card) {
    return
      Image.asset(
        'assets/${card.rank}.${card.suit}.png',
        width: 100, // Set the desired width
        height: 100, // Set the desired height


      );
  }

  Widget _buildPlayerHand() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: playerHand.map((card) {
          return Container(
              child:_buildCardWidget(card)
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blackjack'),
      ),
      body: Container(
        decoration: BoxDecoration(
        color: Colors.green
        ),
        child: Container(
          height: double.infinity,
            child: isPlaying
                ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 50),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCardWidget(
                                dealerHand[0]), // Show first card of dealer

                            if (dealerHand.isNotEmpty)
                              if (showDealerSecondCard)
                                ...dealerHand
                                    .getRange(1, dealerHand.length)
                                    .map((card) => _buildCardWidget(card))
                                    .toList()
                              else
                                Image.asset(
                                  'assets/back1.png',
                                  width: 100, // Set the desired width
                                  height: 100, // Set the desired height

                                ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(

                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child:  Text(
                          '  Dealer Sum: ${showDealerSecondCard ? dealerSum : ''}  ',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 105),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center
                    ,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            onPressed: hitPlayer,
                            icon: Icon(Icons.add_box),
                            iconSize: 50,
                            color: Colors.blue,

                          ),
                          SizedBox(height: 8,),
                          Text("Hit")
                        ],
                      ),

                      SizedBox(width: 25,),
                      Column(
                        children: [

                          IconButton(
                            onPressed: standPlayer,
                            icon: Icon(Icons.front_hand_sharp),
                            iconSize: 50,
                            color: Colors.redAccent,
                          ),
                          SizedBox(height: 8,),
                          Text("Stand")
                        ],
                      )




                    ],
                  ),
                  SizedBox(height: 105),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Container(
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child:Text(
                          '  Player Sum: $playerSum  ',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 10,),
                      _buildPlayerHand(),
                    ],
                  ),
                ],
              ),
            )
                : SingleChildScrollView(
              child:
              Container(

                child: Column(

                    children: [
                      SizedBox(
                        height: 10,
                      ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Row(
                       children: [
                         SizedBox(width: 10,),
                         ElevatedButton(
                           onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => ResultPage(
                                   username: "${widget.name}",
                                 ),
                               ),
                             );
                           },
                           child: Text('View Results'),
                         ),
                       ],
                     ),
                      Row(children: [Icon(Icons.account_balance_wallet),
                        Text(
                          ': $balance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(width: 10,)],)

                    ],
                  ),
                SizedBox(
                  height: 200,
                ),


                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black12, // Transparent color to match background
                            Colors.black12,
                            Colors.black26,
                            Colors.black26,
                            Colors.black12,
                            Colors.black12,// Grey color at the bottom
                            // Grey color at the bottom
                          ],
                        ),
                      ),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                bet = 0; // Reset bet amount to 0
                                // Clear error message
                              });
                            },
                            child:Container(

                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),

                                child: Icon(Icons.clear_sharp,
                                  size: 40,)
                            ),
                          ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 180,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bet += 10; // Reset bet amount to 0
                                            // Clear error message
                                          });
                                        },
                                        child: Container(
                                          width: 50, // Set your desired width
                                          height: 50, // Set your desired height
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor, // Use app's background color
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              "assets/10.png",
                                              width: 50, // Set your desired width
                                              height: 50,// Adjust as needed
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),


                                      SizedBox(
                                        width: 10,
                                      ),


                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bet += 50; // Reset bet amount to 0
                                            // Clear error message
                                          });
                                        },
                                        child: Container(
                                            width: 50, // Set your desired width
                                            height: 50,// Set your desired height
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor, // Use app's background color
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              "assets/50.png",
                                              width: 50, // Set your desired width
                                              height: 50, // Adjust as needed
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),



                                      SizedBox(
                                        width: 10,
                                      ),

                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bet += 100; // Reset bet amount to 0
                                            // Clear error message
                                          });
                                        },
                                        child: Container(
                                          width: 50, // Set your desired width
                                          height: 50, // Set your desired height
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor, // Use app's background color
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              "assets/100.png",
                                              width: 50, // Set your desired width
                                              height: 50, // Adjust as needed
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),





                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bet += 500; // Reset bet amount to 0
                                            // Clear error message
                                          });
                                        },
                                        child: Container(
                                          width: 50, // Set your desired width
                                          height: 50, // Set your desired height
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor, // Use app's background color
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              "assets/500.png",
                                              width: 50, // Set your desired width
                                              height: 50, // Adjust as needed
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),





                                      SizedBox(
                                        width: 10,
                                      ),


                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bet += 1000; // Reset bet amount to 0
                                            // Clear error message
                                          });
                                        },
                                        child: Container(
                                          width: 50, // Set your desired width
                                          height: 50, // Set your desired height
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor, // Use app's background color
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              "assets/1000.png",
                                              width: 50, // Set your desired width
                                              height: 50,// Adjust as needed
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),








                                      // Example text, you can replace this with your text
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),

                              Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(15)


                                  ),
                                  child: Center(
                                    child:Text(' $bet ', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 24)),

                                  )
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0), // Adjust the value to change the roundness
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (bet == 0) {
                                    // Show error message if bet amount is zero
                                    setState(() {
                                      errorMessage = 'Select a bet amount!';
                                    });
                                  } else {
                                    // Set isBetSelected to true only when the Final button is pressed
                                    setState(() {
                                      isBetSelected = true;
                                    });
                                    _playBlackjack(bet);

                                  }
                                },
                                child: Column(
                                  children: [
                                    Text(' Play ', style: TextStyle(color: Colors.black)),
                                    if (errorMessage.isNotEmpty) // Display error message if not empty
                                      Text(errorMessage, style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),

                            ],) ,

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                bet = bet*2; // Reset bet amount to 0
                                // Clear error message
                              });
                            },
                            child:  Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,


                                ),
                                child: Center(
                                  child:Text("x2",style: TextStyle(fontSize: 32 )),

                                )      ),
                          ),




                        ],
                      ),



                    ),
                    SizedBox(height: 20),



                  ],
                ),

              )
             )
        ),
      ),
    );
  }

  int _calculateSum(List<CardModel> hand) {
    int sum = 0;
    for (var card in hand) {
      sum += card.value;
    }
    return sum;
  }

  Future<void> updateUserStats(
      String username, int wins, int losses, int ties) async {
    final response = await http.put(
      Uri.parse('http://$baseurl/users/$username/results'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'wins': wins,
        'losses': losses,
        'ties': ties,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to update user stats: ${response.reasonPhrase}');
    }
  }
}

class ResultPage extends StatefulWidget {
  final String username;

  ResultPage({required this.username});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<dynamic> results = [];
  int totalWins = 0;
  int totalLosses = 0;
  int totalTies = 0;
  int selectedOption = 5; // Default selected option

  @override
  void initState() {
    super.initState();
    fetchResults();
    fetchUserStats(widget.username);
  }

  void fetchResults() async {
    final response = await http.get(
      Uri.parse('http://$baseurl/api/results/${widget.username}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        results = json.decode(response.body);
      });
    } else {
      print('Failed to fetch results: ${response.reasonPhrase}');
    }
  }

  void fetchUserStats(String username) async {
    final response = await http.get(
        Uri.parse('http://$baseurl/users/$username/results'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        totalWins = jsonData['wins'];
        totalLosses = jsonData['losses'];
        totalTies = jsonData['ties'];
      });
    } else {
      print('Failed to fetch user stats: ${response.reasonPhrase}');
    }
  }


  @override
  Widget build(BuildContext context) {
    List<dynamic> reversedResults = List.from(results.reversed);

    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Total Results'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total Wins: $totalWins',
                            style: TextStyle(color: Colors.green)),
                        Text('Total Losses: $totalLosses',
                            style: TextStyle(color: Colors.red)),
                        Text('Total Ties: $totalTies',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [  SizedBox(width: 10,),
            DropdownButton<int>(
              value: selectedOption,
              hint: Text("Show"),
              onChanged: (newValue) {
                setState(() {
                  selectedOption = newValue!;
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text('Last 5'),
                  value: 5,
                ),
                DropdownMenuItem(
                  child: Text('Last 10'),
                  value: 10,
                ),
                DropdownMenuItem(
                  child: Text('Last 20'),
                  value: 20,
                ),
                DropdownMenuItem(
                  child: Text('All'),
                  value: results.length,
                ),
              ],
            ),
          ],
        ),
          Expanded(
            child: ListView.builder(
              reverse: false, // Latest result on top
              itemCount: selectedOption <= results.length
                  ? selectedOption
                  : results.length,
              itemBuilder: (context, index) {
                var result = reversedResults[index];
                String resultText = result['ies_result'];
                int betAmount = result['amount'];
                int amountWon = result['amount_won'];
                Color textColor =
                resultText == 'Loss' ? Colors.red : Colors.green;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200],
                    ),
                    child: ListTile(
                      title: Text(resultText),
                      subtitle: Text('Bet: $betAmount ',
                          style: TextStyle(color: textColor)),
                      trailing: Text('Amount: $amountWon',
                          style: TextStyle(color: textColor)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
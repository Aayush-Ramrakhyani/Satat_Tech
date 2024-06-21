import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:satat_tech_project/History.dart';
import 'package:satat_tech_project/RandomQuates.dart'; // Import for TextInputFormatter

class ADDState extends StatefulWidget {
  const ADDState({Key? key}) : super(key: key);

  @override
  State<ADDState> createState() => _ADDStateState();
}

class _ADDStateState extends State<ADDState> {
  TextEditingController adder1 = TextEditingController();
  TextEditingController adder2 = TextEditingController();
  String result = '';
  String Quotes = '';
  List<Map<String, dynamic>> history = [];
  bool visiable = false;


  @override
  void initState() {
    super.initState();
    getDailyQuote().then((quote) {
      setState(() {
        Quotes = quote;
      });
    });
    fetchHistory();
    adder1.addListener(calculateSum);
    adder2.addListener(calculateSum);
  }

  void calculateSum() {
    // Parse input values
    double value1 = double.tryParse(adder1.text) ?? 0.0;
    double value2 = double.tryParse(adder2.text) ?? 0.0;

    // Calculate sum
    double sum = value1 + value2;

    // Update result text
    setState(() {
      result = sum.toString();
    });

    

  }

  Future<void> saveToHistory(String add1, String add2, String result) async {
    if(adder1.text.isNotEmpty && adder2.text.isNotEmpty)
    {
      await DatabaseHelper().insertHistory(add1, add2, result);
      fetchHistory();
    }
    else
    {
      setState(() {
        visiable = true;
      });
    }
  }

  Future<void> fetchHistory() async {
    List<Map<String, dynamic>> data = await DatabaseHelper().getHistory();
    setState(() {
      history = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            
            children: [
              SizedBox(height: 40),
              Text(
                "Quote of the day",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                "$Quotes",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 50),
              Text(
                "Adder",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 150,
                    child: TextField(
                      controller: adder1,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter number',
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                  ),
                  Text("+"),
                  Container(
                    width: 150,
                    child: TextField(
                      controller: adder2,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter number',
                      ),
                    ),
                  ),
                  Text("="),
                  Text(
                    result,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8,),
              ElevatedButton(onPressed: () {
                saveToHistory(adder1.text, adder2.text, result);
              }, child: Text("Add")),
              SizedBox(height: 20),
              Visibility(visible: visiable ,child: Text("Field Should Not Be Empty" , style: TextStyle(color: Colors.red),)),
              SizedBox(height: 20),
              Text(
                "History",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      title: Text("${item['adder1']} + ${item['adder2']} = ${item['result']}"),
                    );
                  },
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }
}

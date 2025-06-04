import 'dart:async';
import 'dart:convert';
import 'package:ecofinds/screens/home_screen.dart';
import 'package:ecofinds/screens/purchase_history.dart';
import 'package:http/http.dart' as http;
import 'package:ecofinds/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ...other imports...

class ProductBiding extends StatefulWidget {
  final String productId;
  final Map product;

  const ProductBiding(
      {super.key, required this.productId, required this.product});

  @override
  State<ProductBiding> createState() => _ProductBidingState();
}

class _ProductBidingState extends State<ProductBiding> {
  int? cartCount;
  bool _isLoading = false;
  String? _errorMessage;
  String timeLeft = '';
  Timer? _timer;

  // Example bid data
  double highestBid = 0.0;
  double myBid = 0.0;
  List bidHistory = [];

  final _bidController = TextEditingController();

  void openRazorpayCheckout(double _cartTotal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    var options = {
      'key': 'rzp_test_GRmGq7DTX159az',
      'amount': (_cartTotal * 100).toInt(), // Amount in paise!
      'name': userId,
      'description': "EcoFinds Payment",
      'prefill': {"contact": "8888888888", "email": "test@razorpay.com"}
    };
    try {
      print('Opening Razorpay...');
      _razorpay.open(options);
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _startTimer() {
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
    });
  }

  // void BidLose(context, String purchaseDataMsg) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('You have Lost the Bid'),
  //       content: Text('${purchaseDataMsg.toString()} Better Luck Next Time!'),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void BidWon(context, purchaseDataMsg) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('You have Won the Bid'),
  //       content: Text('${purchaseDataMsg.toString()} Proceed to pay!'),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  late Razorpay _razorpay;

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Handling Success');
    checkWinner(pay: true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomeScreen();
    }));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    //
  }

  void BidLose(BuildContext context, String purchaseDataMsg) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Bid Lose",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.red, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'You have Lost the Bid',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Better Luck Next Time!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.sentiment_dissatisfied),
                    label: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  void BidWon(BuildContext context, String purchaseDataMsg) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Bid Won",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: Colors.green, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'You have Won the Bid!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pls. Proceed to pay!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('OK'),
                    onPressed: () {
                      openRazorpayCheckout(highestBid);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  void checkWinner({bool pay = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    final purchaseResponse = await http.post(
      Uri.parse('$baseUrl/purchases/bid_sale.php'),
      body: {
        'pay': pay ? '1' : '0',
        'product_id': widget.productId ?? '',
        // Add other required fields, e.g. cart items, total, etc.
      },
    );

    if (purchaseResponse.statusCode == 200) {
      var purchaseData = jsonDecode(purchaseResponse.body);
      if (pay == true) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PurchaseHistoryScreen();
        }));
      }
      if (pay == false) {
        try {
          if (purchaseData["type"] == "1") {
            if (purchaseData["msg"].toString().split(':')[0] == userId) {
              BidWon(context, purchaseData["msg"]);
            } else {
              BidLose(context, purchaseData["msg"]);
            }
          } else {
            BidLose(context, purchaseData["msg"]);
          }
        } catch (e) {
          print('Error: $e');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase failed. Please try again.')),
      );
    }
  }

  void _updateTimeLeft() {
    final endTimeStr = widget.product['auction_end_time'];
    if (endTimeStr == null || endTimeStr.isEmpty) {
      setState(() {
        timeLeft = 'No end time';
        _timer?.cancel();
      });
      return;
    }
    try {
      final endTime = DateTime.parse(endTimeStr.replaceFirst(' ', 'T'));
      final now = DateTime.now();
      final diff = endTime.difference(now);
      if (diff.isNegative) {
        setState(() {
          timeLeft = 'Auction ended';
          checkWinner();
          _timer?.cancel();
        });
      } else {
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;
        setState(() {
          timeLeft = '${hours.toString().padLeft(2, '0')}:'
              '${minutes.toString().padLeft(2, '0')}:'
              '${seconds.toString().padLeft(2, '0')} left';
        });
      }
    } catch (e) {
      setState(() {
        timeLeft = 'Invalid end time';
        _timer?.cancel();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchBidDetails();
    fetchOngoingBids();
    _startTimer();
  }

  void fetchOngoingBids() async {
    print('$baseUrl/bids/ongoing.php?product_id=${widget.productId}');
    print('$baseUrl/bids/ongoing.php?product_id=${widget.productId}');
    print('$baseUrl/bids/ongoing.php?product_id=${widget.productId}');
    print('$baseUrl/bids/ongoing.php?product_id=${widget.productId}');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bids/ongoing.php?product_id=${widget.productId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          bidHistory = jsonDecode(response.body);
          print(bidHistory.toString());
        });
      }
    } catch (e) {}
  }

  Future<void> placeBid() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final productId = widget.productId;
    final amountStr = _bidController.text.trim();

    if (userId == null || amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bid amount.')),
      );
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number.')),
      );
      return;
    }

    if (amount <= highestBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Your bid must be greater than the current highest bid (₹$highestBid).')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bids/place.php'),
        body: {
          'user_id': userId,
          'product_id': productId,
          'amount': amountStr,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? 'Bid placed successfully.')),
        );
        _bidController.clear();
        fetchBidDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to place bid.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error placing bid.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // TODO: Implement fetchHighestBid, fetchBidHistory, placeBid, etc.
  Future<void> fetchBidDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final productId = widget.productId;

    if (userId == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/bids/myBidDetails.php?product_id=$productId&user_id=$userId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          highestBid = double.tryParse(data['max_amount'].toString()) ?? 0.0;
          myBid = double.tryParse(data['my_amount'].toString()) ?? 0.0;
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Auction: ' + widget.product['title']),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Your Bid', icon: Icon(Icons.gavel)),
              Tab(text: 'Product Info', icon: Icon(Icons.info)),
              Tab(text: 'Ongoing Bids', icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'Time left: $timeLeft',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Bid
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Highest Bid: ₹$highestBid',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Your Bid: ₹$myBid'),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bidController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Enter your bid',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape:
                                  WidgetStatePropertyAll(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                              backgroundColor:
                                  WidgetStatePropertyAll(AppColors.primary),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: () {
                              placeBid();
                            },
                            child: const Text('Place Bid'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab 2: Info
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: Image.network(
                            '$baseUrl/products/${widget.product['image_url']}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.broken_image, size: 60)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(widget.product['title'],
                            style: AppTextStyles.heading1),
                        const SizedBox(height: 8),
                        Text("\Rs.${widget.product['price'].toString()}",
                            style: AppTextStyles.priceText),
                        const SizedBox(height: 16),
                        Text(widget.product['description'],
                            style: AppTextStyles.bodyText),
                      ],
                    ),
                  ),
                  // Tab 3: Bids
                  // Tab 3: Ongoing Bids (Redesigned)
                  bidHistory.isEmpty
                      ? const Center(
                          child: Text('No bids yet.',
                              style: TextStyle(fontSize: 16)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: bidHistory.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final bid = bidHistory[index];
                            final isLatest = index == 0;
                            return Card(
                              elevation: isLatest ? 6 : 2,
                              color: isLatest
                                  ? Colors.green.shade50
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isLatest
                                    ? BorderSide(
                                        color: Colors.green.shade300, width: 2)
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                leading: CircleAvatar(
                                  backgroundColor: isLatest
                                      ? Colors.green.shade400
                                      : Colors.grey.shade300,
                                  child: Icon(
                                    isLatest ? Icons.star : Icons.gavel,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  '₹${bid['bid_amount']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isLatest
                                        ? Colors.green.shade700
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bid Time: ${bid['bid_dt']}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    // You can add more info here if needed
                                  ],
                                ),
                                trailing: isLatest
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Latest',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

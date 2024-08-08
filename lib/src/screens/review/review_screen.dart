// ignore_for_file: use_build_context_synchronously

import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/models/review_model.dart';
import 'package:heathbridge_lao/src/provider/review_provider.dart';

class ReviewScreen extends StatefulWidget {
  final double initialRating;
  final String facId;

  const ReviewScreen({
    super.key,
    required this.initialRating,
    required this.facId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  UserModel? user;
  bool isLoading = true;
  double rating = 0;
  final TextEditingController reviewTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      await context
          .read<UserProvider>()
          .fetchUser(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        user = context.read<UserProvider>().userModel.first;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching user: $e");
    }
  }

  void _postReview() async {
    final reviewText = reviewTextController.text.trim();
    if (reviewText.isNotEmpty && rating > 0) {
      final review = ReviewModel(
        rating: rating,
        description: reviewText,
        createdAt: DateTime.now(),
      );

      try {
        final success = await context.read<ReviewProvider>().postReview(
              review: review,
              facilityId: widget.facId,
              userId: user!.userId!,
            );

        if (success) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post review.')),
          );
        }
      } catch (e) {
        debugPrint("Error posting review: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPosting = context.watch<ReviewProvider>().isPosting;

    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: ConstantColor.colorMain,
      minimumSize: const Size(double.infinity, 36),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ການສະເເດງຄວາມຄິດເຫັນ'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: const CircleAvatar(),
                    ),
                    title: Text(
                      '${user?.firstname ?? 'No Name'} ${user?.lastname ?? 'No lastname'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.tel ?? "No Email",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.info_outline),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: TextFormField(
                      controller: reviewTextController,
                      minLines: 4,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        hintText:
                            'ເເບ່ງປັນປະສົບການ ຫຼື ຄວາມຄິດຂອງທ່ານກ່ຽວກັບສະຖານທີ່ນີ້',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      ),
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        this.rating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  isPosting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: raisedButtonStyle,
                          onPressed: _postReview,
                          child: const Text('ບັນທຶກການສະເເດງຄວາມຄິດເຫັນ'),
                        ),
                ],
              ),
            ),
    );
  }
}

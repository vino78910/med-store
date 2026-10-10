import '../models/user_model.dart';
import 'sample_data_service.dart';

class AuthService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // In production with Firebase Auth:
    // UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    // DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
    // return UserModel.fromMap(doc.data() as Map<String, dynamic>, cred.user!.uid);

    if (email.contains('admin')) {
      _currentUser = SampleDataService.getSamplePharmacyAdmin();
    } else if (email.contains('pharm') || email.contains('sarah')) {
      _currentUser = SampleDataService.getSamplePharmacist();
    } else {
      _currentUser = SampleDataService.getSamplePatient();
    }
    return _currentUser!;
  }

  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? pharmacyId,
    String? pharmacyName,
    String? phoneNumber,
    String? address,
  }) async {
    // In production with Firebase Auth:
    // UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    // await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set(userModel.toMap());

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      phoneNumber: phoneNumber,
      address: address,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    // await FirebaseAuth.instance.signOut();
    _currentUser = null;
  }
}

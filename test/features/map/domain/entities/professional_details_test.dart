import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/map/domain/entities/entities.dart';

void main() {
  group('ProfessionalDetails', () {
    test('should create from JSON correctly', () {
      final json = {
        'proProfileId': 'test-pro-id',
        'fullName': 'John Doe',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'businessName': 'John Photography',
        'profession': 'photographer',
        'budgetMin': 1000,
        'budgetMax': 5000,
        'currency': 'EUR',
        'subscriptionTier': 'premiumVisibility',
        'distanceKm': 15.5,
        'locationLabel': 'Paris, France',
        'isFavorited': true,
        'isLive': true,
        'description': 'Professional photographer',
        'portfolioImages': ['img1.jpg', 'img2.jpg'],
        'canBeContactedByBride': true,
      };

      final details = ProfessionalDetails.fromJson(json);

      expect(details.id, 'test-pro-id');
      expect(details.fullName, 'John Doe');
      expect(details.businessName, 'John Photography');
      expect(details.profession, Profession.photographer);
      expect(details.budgetMin, 1000);
      expect(details.budgetMax, 5000);
      expect(details.subscriptionTier, SubscriptionTier.premiumVisibility);
      expect(details.distanceKm, 15.5);
      expect(details.isFavorited, true);
      expect(details.portfolioImages.length, 2);
    });

    test('displayName should return businessName if available', () {
      const details = ProfessionalDetails(
        id: 'test',
        fullName: 'John Doe',
        businessName: 'John Photography',
        profession: Profession.photographer,
      );

      expect(details.displayName, 'John Photography');
    });

    test('displayName should return fullName if no businessName', () {
      const details = ProfessionalDetails(
        id: 'test',
        fullName: 'John Doe',
        profession: Profession.photographer,
      );

      expect(details.displayName, 'John Doe');
    });

    test('budgetRangeOriginal should format correctly', () {
      const details = ProfessionalDetails(
        id: 'test',
        fullName: 'John Doe',
        profession: Profession.photographer,
        budgetMin: 1000,
        budgetMax: 5000,
        currency: 'EUR',
      );

      expect(details.budgetRangeOriginal, '1000 - 5000 EUR');
    });

    test('distanceFormattedKm should format km correctly', () {
      const details = ProfessionalDetails(
        id: 'test',
        fullName: 'John Doe',
        profession: Profession.photographer,
        distanceKm: 15.5,
      );

      expect(details.distanceFormattedKm, '15.5 km');
    });

    test('distanceFormattedKm should format meters for < 1km', () {
      const details = ProfessionalDetails(
        id: 'test',
        fullName: 'John Doe',
        profession: Profession.photographer,
        distanceKm: 0.5,
      );

      expect(details.distanceFormattedKm, '500 m');
    });
  });

  group('Profession', () {
    test('fromString should parse correctly', () {
      expect(Profession.fromString('photographer'), Profession.photographer);
      expect(Profession.fromString('PHOTOGRAPHER'), Profession.photographer);
      expect(Profession.fromString('filmmaker'), Profession.filmmaker);
      expect(Profession.fromString('planner'), Profession.planner);
      expect(Profession.fromString('unknown'), Profession.other);
      expect(Profession.fromString(null), Profession.other);
    });

    test('displayName should return correct labels', () {
      expect(Profession.photographer.displayName, 'Photographer');
      expect(Profession.filmmaker.displayName, 'Filmmaker');
      expect(Profession.planner.displayName, 'Wedding Planner');
      expect(Profession.makeupArtist.displayName, 'Makeup Artist');
    });
  });

  group('SubscriptionTier', () {
    test('fromString should parse correctly', () {
      expect(SubscriptionTier.fromString('premiumVisibility'), SubscriptionTier.premiumVisibility);
      expect(SubscriptionTier.fromString('premium_visibility'), SubscriptionTier.premiumVisibility);
      expect(SubscriptionTier.fromString('ultimateAccess'), SubscriptionTier.ultimateAccess);
      expect(SubscriptionTier.fromString('earlyAccess'), SubscriptionTier.earlyAccess);
      expect(SubscriptionTier.fromString('trial'), SubscriptionTier.trial);
      expect(SubscriptionTier.fromString('unknown'), SubscriptionTier.inactive);
      expect(SubscriptionTier.fromString(null), SubscriptionTier.inactive);
    });

    test('displayName should return correct labels', () {
      expect(SubscriptionTier.inactive.displayName, 'Inactive');
      expect(SubscriptionTier.trial.displayName, 'Trial');
      expect(SubscriptionTier.premiumVisibility.displayName, 'Premium');
      expect(SubscriptionTier.ultimateAccess.displayName, 'Ultimate');
    });
  });
}

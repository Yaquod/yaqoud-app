import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yaqood/Constants/constants.dart';
import 'package:yaqood/Enums/ride_step.dart';
import 'package:yaqood/Services/location_service.dart';
import 'package:yaqood/Services/map_helper.dart';
import 'package:yaqood/Services/map_routing_service.dart';
import 'package:yaqood/Services/trip_api_service.dart';
import 'package:yaqood/Widgets/App_Drawer.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Widgets/Map/map_buttons.dart';
import 'package:yaqood/Widgets/Map/map_center_pin.dart';
import 'package:yaqood/Widgets/Map/map_info_window.dart';
import 'package:yaqood/Widgets/Primary_color.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:yaqood/Widgets/Trip_Dialog_body.dart';
import 'package:yaqood/Widgets/confirm_trip_widget.dart';
import 'package:yaqood/Widgets/location_search_widget.dart';
import 'package:yaqood/Widgets/payment_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.initialTripId});
  final String? initialTripId;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GoogleMapController? mapController;
  DraggableScrollableController sheetController =
      DraggableScrollableController();

  bool hasPermission = false;
  bool isMapMoving = false;
  bool isFirstTime = true;
  bool isSelectedFromSearch = false;
  bool showInfoWindow = true;
  bool hasRoute = false;
  bool isTripDialogShown = false;

  LatLng? startLocation;
  LatLng? currentLocation;
  LatLng? destinationLocation;

  String? startStreetName;
  String? destinationStreetName;
  String? currentTripStatus;
  String? tripRequestId;

  CameraPosition? lastCameraPosition;
  StreamSubscription<Position>? positionStream;

  TextEditingController startController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  double sheetSize = 0.2;

  FocusNode startFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();

  GoogleApiConfig googleApiConfig = GoogleApiConfig(
    apiKey: dotenv.env["GOOGLE_MAPS_API_KEY"]!,
    fetchPlaceDetailsWithCoordinates: true,
  );

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};

  late VoidCallback _startFocusListener;
  late VoidCallback _destinationFocusListener;

  Timer? tripPollingTimer;

  RideStep currentStep = RideStep.initial;

  final LocationService _locationService = LocationService();
  final MapRoutingService _mapRoutingService = MapRoutingService();
  final TripApiService _tripApiService = TripApiService();

  // assign start Location to it`s textField
  void updatesStartFieldWithStartLocation() async {
    if (currentLocation == null) return;

    String street = await _locationService.getStreetName(startLocation!);

    setState(() {
      startController.text = street;
    });
  }

  // Location Stream
  void currentLocationStream() async {
    hasPermission = await _locationService.checkLocationPermission();

    if (!hasPermission) return;

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,

            distanceFilter: 5,
          ),
        ).listen((Position position) async {
          if (!mounted) return;

          LatLng newLatLng = LatLng(position.latitude, position.longitude);
          currentLocation = newLatLng;

          if (startLocation == null && !isSelectedFromSearch && !isMapMoving) {
            String street = await _locationService.getStreetName(newLatLng);

            setState(() {
              startLocation = newLatLng;
              startStreetName = street;
              startController.text = street;
            });

            mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
          }
        });
  }

  //  Location Markers
  Set<Marker> getMarkers() {
    Set<Marker> markersSet = {};

    if (startLocation != null) {
      markersSet.add(
        Marker(
          markerId: MarkerId("start"),
          position: startLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    if (destinationLocation != null) {
      markersSet.add(
        Marker(
          markerId: MarkerId("end"),
          position: destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markersSet;
  }

  // Create route between start and destinatin locations and mange zooming
  void createRoute(LatLng start, LatLng destination) async {
    setState(() {
      showInfoWindow = false;
      hasRoute = true;
    });

    polylineCoordinates.clear();
    polylines.clear();

    print("*************** lat: ${start.latitude} *********************");
    print("*************** long: ${start.longitude} *********************");

    final routeData = await _mapRoutingService.getRouteData(
      start: start,
      destination: destination,
    );

    List<LatLng> points = (routeData['coordinates'] as List).cast<LatLng>();
    Set<Polyline> computedPolylines = (routeData['polylines'] as Set)
        .cast<Polyline>();

    if (points.isNotEmpty) {
      setState(() {
        polylineCoordinates = points;
        polylines = computedPolylines;
      });

      if (polylineCoordinates.isNotEmpty) {
        focusOnRoute();
      }
    } else {
      setState(() {
        hasRoute = false;
        showInfoWindow = true;
      });
    }
  }

  // FocusOnRoute
  void focusOnRoute() async {
    MapHelper.animateToRoute(mapController, polylineCoordinates);

    if (sheetController.isAttached) {
      double targetSize = (currentStep == RideStep.confirmTrip)
          ? 0.42
          : Constants.minSheetSize;

      openSheet(targetSize);
    }
  }

  // clear Route
  void clearRoute() {
    setState(() {
      hasRoute = false;
      showInfoWindow = true;
      polylineCoordinates.clear();
      polylines.clear();
    });
  }

  // Clear Destination;
  void clearDestinaton() {
    setState(() {
      destinationController.clear();
      destinationLocation = null;
      destinationStreetName = null;
    });
  }

  // Bottom sheet animation
  void openSheet(double size) {
    if (!sheetController.isAttached) return;

    if ((sheetController.size - size).abs() < 0.02) return;

    sheetController.animateTo(
      size,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Start Trip Flow
  Future<void> startTripFlow() async {
    if (startLocation == null || destinationLocation == null) return;

    final result = await _tripApiService.requestTrip(
      start: LatLng(startLocation!.latitude, startLocation!.longitude),
      destination: LatLng(
        destinationLocation!.latitude,
        destinationLocation!.longitude,
      ),
    );

    if (result == null) return;

    if (result["error_type"] == "auth_error") {
      showSnackBar(context: context, message: "Login expired");
      return;
    }

    if (result["error_type"] == "network_error") {
      showSnackBar(context: context, message: "Network error");
      return;
    }

    if (result["success"] == true && result["data"]["status"] == "PENDING") {
      isTripDialogShown = true;
      tripRequestId = result["data"]["id"].toString();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,

        body: Column(
          children: [
            Gap(24),

            Text(
              "Finding a nearby Vehicle",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Gap(10),

            Text(
              "Locating the nearest autonomous taxi",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            Gap(40),
            CircularProgressIndicator(color: PrimaryColor),

            Gap(24),
          ],
        ),
      ).show();

      startTripPolling();
    }
  }

  // start Trip HTTP Polling
  void startTripPolling() {
    tripPollingTimer?.cancel();

    if (tripRequestId == null) return;

    tripPollingTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final result = await _tripApiService.getTripStatus(tripRequestId!);

      if (result == null) return;

      final data = result["data"];
      if (data == null) {
        print("Warning: result['data'] is null, skipping this polling tick");
        return;
      }

      // Safely extract values with null checks and type casting
      final status = data['status'] as String?;
      final estimatedTimeValue = data['estimatedTime'];
      final estimatedFareValue = data['estimatedFare'];

      // Validate that status is not null
      if (status == null) {
        print("Warning: status is null, skipping this polling tick");
        return;
      }

      final estimatedTime = estimatedTimeValue != null
          ? (estimatedTimeValue as num).toDouble()
          : 0.0;
      final estimatedFare = estimatedFareValue != null
          ? (estimatedFareValue as num).toDouble()
          : 0.0;

      currentTripStatus = status;

      handleTripStatus(status, estimatedTime, estimatedFare);
    });
  }

  // Handle Trip Status
  void handleTripStatus(
    String status,
    double estimatedTime,
    double estimatedFare,
  ) {
    if (!mounted) return;

    if (status == "COMPLETED") {
      tripPollingTimer?.cancel();

      if (isTripDialogShown) {
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        isTripDialogShown = false;

        showSnackBar(
          context: context,
          message: "Vehicle Found",
          isError: false,
        );

        AwesomeDialog(
          context: context,
          dialogType: DialogType.noHeader,
          animType: AnimType.rightSlide,
          dismissOnTouchOutside: true,
          headerAnimationLoop: false,
          buttonsBorderRadius: BorderRadius.circular(25),
          dialogBorderRadius: BorderRadius.circular(20),

          btnCancelText: "Reject",
          btnCancelOnPress: () async {
            tripPollingTimer?.cancel();
            await handleDeclineOffer();
          },

          btnOkText: "Accept",
          btnOkOnPress: () async {
            tripPollingTimer?.cancel();
            await handleAcceptOffer();
          },

          buttonsTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),

          body: TripDialogBody(
            startStreetName: startStreetName ?? "Unknown Street name",
            destinationStreetName: destinationStreetName!,
            estimatedTime: estimatedTime,
            estimatedFare: estimatedFare,
            declineOffer: handleDeclineOffer,
          ),
        ).show();
      }
    }
  }

  // Decline Offer
  Future<Map<String, dynamic>?> handleDeclineOffer() async {
    if (tripRequestId == null) return null;

    final result = await _tripApiService.declineOffer(tripRequestId!);

    if (result != null && result["success"] == true) {
      showSnackBar(context: context, message: "Offer Declined", isError: false);
    } else {
      showSnackBar(context: context, message: "Network error");
    }

    return result;
  }

  // Accept Offer
  Future<void> handleAcceptOffer() async {
    if (tripRequestId == null) return;

    try {
      final result = await _tripApiService.acceptOffer(tripRequestId!);

      if (result != null && result["success"] == true) {
        final data = result["data"];
        if (data != null && data["status"] == "ACCEPTED") {
          if (!mounted) return;

          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          showSnackBar(
            context: context,
            message: "Your vehicle is on the way",
            isError: false,
          );
        } else {
          showSnackBar(context: context, message: "Something went wrong");
        }
      } else {
        showSnackBar(context: context, message: "Network error");
      }
    } catch (e) {
      print("Error in handleAcceptOffer: $e");
      if (mounted) {
        showSnackBar(context: context, message: "Error accepting offer");
      }
    }
  }

  void _onStartLocationChanged(LatLng location, Prediction prediction) {
    setState(() {
      isSelectedFromSearch = true;
      startLocation = location;
      final streetName = prediction.description?.split('،')[0] ?? "";
      startController.text = prediction.description!;
      startStreetName = streetName;
    });

    if (startLocation != null && destinationLocation != null) {
      _initializeTrip();
    }
  }

  void _clearStartLocationSearch() {
    setState(() {
      startController.clear();
      startLocation = null;
      startStreetName = null;
      clearRoute();
    });
  }

  void _onDestinationChanged(LatLng location, Prediction prediction) {
    setState(() {
      isSelectedFromSearch = true;
      destinationLocation = location;
      destinationStreetName = prediction.description?.split('،')[0] ?? "";
      destinationController.text = prediction.description!;
    });

    if (startLocation != null && destinationLocation != null) {
      _initializeTrip();
    }
  }

  void _clearDestinationLocationSearch() {
    setState(() {
      destinationController.clear();
      destinationLocation = null;
      destinationStreetName = null;
      clearRoute();
    });
  }

  void _initializeTrip() {
    startFocusNode.unfocus();
    destinationFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    openSheet(Constants.minSheetSize);
    createRoute(startLocation!, destinationLocation!);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        currentStep = RideStep.confirmTrip;
      });

      openSheet(0.42);
    });
  }

  void _handleLocationGPSPressed() {
    if (currentLocation == null) return;

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(startLocation ?? currentLocation!, 16),
    );
  }

  // init State
  @override
  void initState() {
    super.initState();
    currentLocationStream();

    sheetController.addListener(() {
      if (!mounted) return;

      final newSize = sheetController.size;
      if ((sheetSize - newSize).abs() > 0.01) {
        setState(() {
          sheetSize = newSize;
        });
      }
    });

    _startFocusListener = () {
      if (startFocusNode.hasFocus) {
        openSheet(Constants.maxSheetSize);
      }
    };
    startFocusNode.addListener(_startFocusListener);

    _destinationFocusListener = () {
      if (destinationFocusNode.hasFocus) {
        openSheet(Constants.maxSheetSize);
      }
    };
    destinationFocusNode.addListener(_destinationFocusListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      openSheet(Constants.collapseSheetSize);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // String? status = message.data['status'];
      String title = message.notification?.title ?? "";
      String body = message.notification?.body ?? "";
      print("----------------------------------");
      print("title: $title");
      print("body: $body");
      print("----------------------------------");

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: title,
        desc: body,
        btnOkOnPress: () {},
      ).show();
    });
  }

  // dispose
  @override
  void dispose() {
    startController.dispose();
    destinationController.dispose();

    startFocusNode.removeListener(_startFocusListener);
    destinationFocusNode.removeListener(_destinationFocusListener);

    sheetController.dispose();
    mapController?.dispose();
    positionStream?.cancel();

    tripPollingTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator(color: PrimaryColor))
          : Stack(
              children: [
                // Google map
                Positioned.fill(
                  child: GoogleMap(
                    mapType: MapType.normal,

                    markers: getMarkers(),

                    polylines: polylines,

                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,

                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 16,
                    ),

                    onTap: (_) {
                      openSheet(Constants.collapseSheetSize);
                    },

                    onCameraMove: (position) {
                      lastCameraPosition = position;

                      if (!isMapMoving) {
                        setState(() => isMapMoving = true);

                        if (isFirstTime) {
                          isFirstTime = false;
                        } else {
                          openSheet(Constants.minSheetSize);
                        }
                      }
                    },

                    onCameraIdle: () async {
                      if (!mounted || lastCameraPosition == null) return;

                      if (isSelectedFromSearch) {
                        setState(() {
                          isSelectedFromSearch = false;
                          isMapMoving = false;
                          if (!hasRoute) {
                            openSheet(Constants.collapseSheetSize);
                          } else {
                            openSheet(Constants.minSheetSize);
                          }
                        });

                        return;
                      }

                      LatLng targetLocation = lastCameraPosition!.target;

                      setState(() {
                        isMapMoving = false;
                      });

                      String street = await _locationService.getStreetName(
                        targetLocation,
                      );
                      if (!hasRoute) {
                        setState(() {
                          startLocation = targetLocation;
                          startStreetName = street;
                          startController.text = street;
                        });

                        openSheet(Constants.collapseSheetSize);
                      }
                    },

                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),

                if (!hasRoute) MapCenterPin(isMapMoving: isMapMoving),

                // info window
                MapInfoWindow(
                  startStreetName: startStreetName,
                  isMapMoving: isMapMoving,
                  sheetSize: sheetSize,
                  showInfoWindow: showInfoWindow,
                  onTap: () => openSheet(Constants.maxSheetSize),
                ),

                MapDrawerButton(
                  isMapMoving: isMapMoving,
                  sheetSize: sheetSize,
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),

                MapLocationButton(
                  isMapMoving: isMapMoving,
                  sheetSize: sheetSize,
                  hasRoute: hasRoute,
                  onPressed: _handleLocationGPSPressed,
                ),

                MapFocusRouteButton(
                  hasRoute: hasRoute,
                  polylineCoordinates: polylineCoordinates,
                  isMapMoving: isMapMoving,
                  sheetSize: sheetSize,
                  onPressed: focusOnRoute,
                ),

                // Bottom Sheet
                DraggableScrollableSheet(
                  controller: sheetController,

                  initialChildSize: Constants.collapseSheetSize,
                  minChildSize: Constants.minSheetSize,
                  maxChildSize: Constants.maxSheetSize,

                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),

                      child: ListView(
                        controller: scrollController,

                        children: [
                          Icon(Icons.drag_handle),

                          Gap(10),

                          Visibility(
                            visible: currentStep.index <= 1,
                            maintainState: true,
                            child: currentStep == RideStep.initial
                                ? GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();

                                      setState(() {
                                        currentStep = RideStep.search;
                                      });
                                      openSheet(Constants.maxSheetSize);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: PrimaryColor,
                                          ),
                                          const Gap(12),
                                          const Text(
                                            "Where to?",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : LocationSearch(
                                    startController: startController,
                                    destinationController:
                                        destinationController,
                                    startFocusNode: startFocusNode,
                                    destinationFocusNode: destinationFocusNode,
                                    mapController: mapController,
                                    googleApiConfig: googleApiConfig,
                                    onStartLocationChanged:
                                        _onStartLocationChanged,
                                    onDestinationChanged: _onDestinationChanged,
                                    clearStartLocationSearch:
                                        _clearStartLocationSearch,
                                    clearDestinationLocationSearch:
                                        _clearDestinationLocationSearch,
                                  ),
                          ),

                          if (currentStep == RideStep.confirmTrip)
                            ConfirmTripWidget(
                              startStreetName:
                                  startStreetName ?? "Current Location",
                              destinationStreetName: destinationStreetName!,
                              onRequestPressed: () async {
                                await startTripFlow();
                              },
                              onCancelPressed: () {
                                startFocusNode.unfocus();
                                destinationFocusNode.unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();

                                setState(() {
                                  currentStep = RideStep.search;
                                });

                                openSheet(Constants.maxSheetSize);
                              },
                            ),

                          if (currentStep == RideStep.payment)
                            const PaymentWidget(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

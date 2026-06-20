import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class LocationSearch extends StatelessWidget {
  const LocationSearch({
    super.key,
    required this.startController,
    required this.destinationController,
    required this.startFocusNode,
    required this.destinationFocusNode,
    required this.mapController,
    required this.googleApiConfig,
    required this.onStartLocationChanged,
    required this.onDestinationChanged,
    required this.clearStartLocationSearch,
    required this.clearDestinationLocationSearch,
  });
  final TextEditingController startController;
  final TextEditingController destinationController;
  final FocusNode startFocusNode;
  final FocusNode destinationFocusNode;
  final GoogleMapController? mapController;
  final GoogleApiConfig googleApiConfig;

  // Callbacks
  final Function(LatLng, Prediction) onStartLocationChanged;
  final Function() clearStartLocationSearch;
  final Function(LatLng, Prediction) onDestinationChanged;
  final Function() clearDestinationLocationSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // start Location textField
        GooglePlacesAutoCompleteTextFormField(
          key: const ValueKey("startLocation"),
          config: googleApiConfig,
          textEditingController: startController,
          focusNode: startFocusNode,

          decoration: InputDecoration(
            labelText: "Pick up Location",
            focusColor: PrimaryColor,

            border: OutlineInputBorder(),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: PrimaryColor, width: 1),
            ),

            suffixIcon: startController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      clearStartLocationSearch();
                    },
                    icon: Icon(Icons.clear, color: Colors.grey.shade700),
                  )
                : null,
          ),

          maxLines: 1,
          minInputLength: 3,

          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter some text';
            }

            return null;
          },

          overlayContainerBuilder: (child) => Material(
            elevation: 5,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),

            child: child,
          ),

          onPredictionWithCoordinatesReceived: (Prediction prediction) {
            if (prediction.lat == null || prediction.lng == null) {
              return;
            }

            final LatLng selectedLocation = LatLng(
              double.parse(prediction.lat!),
              double.parse(prediction.lng!),
            );

            FocusScope.of(context).unfocus();

            onStartLocationChanged(selectedLocation, prediction);

          },
        ),

        Gap(20),

        // Destination Location textField
        GooglePlacesAutoCompleteTextFormField(
          key: const ValueKey("destinationKey"),
          config: googleApiConfig,
          textEditingController: destinationController,
          focusNode: destinationFocusNode,

          decoration: InputDecoration(
            labelText: "What is your Destination ?",
            focusColor: PrimaryColor,

            border: OutlineInputBorder(),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: PrimaryColor, width: 1),
            ),

            suffixIcon: destinationController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      clearDestinationLocationSearch();
                    },
                    icon: Icon(Icons.clear, color: Colors.grey.shade700),
                  )
                : null,
          ),

          maxLines: 1,
          minInputLength: 3,

          validator: (value) {
            if (value!.isEmpty) {
              return 'Choose your destination';
            }

            return null;
          },

          overlayContainerBuilder: (child) => Material(
            elevation: 5,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),

            child: child,
          ),

          onPredictionWithCoordinatesReceived: (Prediction prediction) {
            if (prediction.lat == null || prediction.lng == null) {
              return;
            }

            final LatLng selectedLocation = LatLng(
              double.parse(prediction.lat!),
              double.parse(prediction.lng!),
            );

            FocusScope.of(context).unfocus();

            onDestinationChanged(selectedLocation, prediction);
          },
        ),
      ],
    );
  }
}

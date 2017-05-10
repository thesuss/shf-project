# put Geocoder into test mode so we don't have to make calls to the Google Maps API in test mode

# Will have to manually set the information returned by Geocoder

Geocoder.configure(lookup: :test)


# Need to override this method because we want Geocoder to return nil if it cannot find the information.
# The original code in the gem will raise an error.
# nil is meaningful to us; we want it if an address cannot be geocoded
# We have to do this so we can test the Address .geocode_best_possible  method
#
#  original code is commented out
 Geocoder::Lookup::Test.module_eval {

   def self.read_stub(query_text)
     stubs.fetch(query_text) {
       # original code:
       # return @default_stub unless @default_stub.nil?
       # raise ArgumentError, "unknown stub request #{query_text}"
       if @default_stub.nil?
          {}
       else
         @default_stub
       end

     }
   end
 }


# --------
# information returned by Geocoder when it uses the :test lookup:

Geocoder::Lookup::Test.add_stub(

    "Sverige",
    [
        {
            'latitude'     => 60.12816100000001,
            'longitude'    => 18.643501,
            'address'      => 'Sverige',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(

    "Harplinge, Sverige",
    [
        {
            'latitude'     => 56.7422437,
            'longitude'    => 12.7206453,
            'address'      => 'Harplinge, Sverige',
            'city'         => 'Harplinge',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(

    "310 40, Harplinge, Sverige",
    [
        {
            'latitude'     => 56.7422437,
            'longitude'    => 12.7206453,
            'address'      => '310 40, Harplinge, Sverige',
            'city'         => 'Harplinge',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ],
)


Geocoder::Lookup::Test.add_stub(

    "Hundvägen 101, 310 40, Harplinge, Sverige",
    [
        {
            'latitude'     => 56.7422437,
            'longitude'    => 12.7206453,
            'address'      => 'Hundvägen 101, 310 40, Harplinge, Sverige',
            'city'         => 'Harplinge',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ],
)


Geocoder::Lookup::Test.add_stub(

    "Hundforetagarevägen 1, 310 40, Harplinge, Ale, Sverige",
    [
        {
            'latitude'     => 56.7422437,
            'longitude'    => 12.7206453,
            'address'      => 'Hundforetagarevägen 1, 310 40, Harplinge, Ale, Sverige',
            'city'         => 'Harplinge',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ],
)


Geocoder::Lookup::Test.add_stub(

    "Kvarnliden 10, 310 40, Harplinge, Sverige",
    [
        {
            'latitude'     => 56.7440333,
            'longitude'    => 12.727637,
            'address'      => 'Kvarnliden 10, 310 40, Harplinge, Sverige',
            'city'         => 'Harplinge',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(

    "Kvarnliden 10, 310 40, Harplinge, Halland, Sverige",
    [
        {
            'latitude'     => 56.7440333,
            'longitude'    => 12.727637,
            'address'      => 'Kvarnliden 10, 310 40, Harplinge, Halland, Sverige',
            'city'         => 'Harplinge',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)



Geocoder::Lookup::Test.add_stub(

    "Kvarnliden 2, 310 40, Harplinge, Halland, Sverige",
    [
        {
            'latitude'     => 56.7442343,
            'longitude'    => 12.7255982,
            'address'      => 'Kvarnliden 2, 310 40, Harplinge, Halland, Sverige',
            'city'         => 'Harplinge',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(

    "Kvarnliden 10, 310 40, Harplinge, Halmstad Ö, Sverige",
    [
        {
            'latitude'     => 56.7440333,
            'longitude'    => 12.727637,
            'address'      => 'Kvarnliden 10, 310 40, Harplinge,  Halmstad Ö, Sverige',
            'city'         => 'Harplinge',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)



Geocoder::Lookup::Test.add_stub(

    "Plingshult, Halland, Sverige",
    [
        {
            'latitude'     => 56.607677,
            'longitude'    => 13.251166,
            'address'      => 'Plingshult, Halland, Sverige',
            'city'         => 'Plingshult',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(

    "Norway",
    [
        {
            'latitude'     => 60.47202399999999,
            'longitude'    => 8.468945999999999,
            'address'      => 'Norway',
            'country'      => 'Norway',
        }
    ]
)



Geocoder::Lookup::Test.add_stub(

    "Matarengivägen 24, 957 31, Övertorneå, Norrbotten, Sverige",
    [
        {
            'latitude'     => 66.3902539,
            'longitude'    => 23.6601303,
            'address'      => 'Matarengivägen 24, 957 31, Övertorneå, Norrbotten, Sverige',
            'city'         => 'Övertorneå',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(

    "957 31, Övertorneå, Norrbotten, Sverige",
    [
        {
            'latitude'     => 66.3887731,
            'longitude'    => 23.6734973,
            'address'      => '957 31, Övertorneå, Norrbotten, Sverige',
            'city'         => 'Övertorneå',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(

    "Övertorneå, Norrbotten, Sverige",
    [
        {
            'latitude'     => 66.3884436,
            'longitude'    => 23.639283,
            'address'      => 'Övertorneå, Norrbotten, Sverige',
            'city'         => 'Övertorneå',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)

Geocoder::Lookup::Test.add_stub(

    "Norrbotten, Sverige",
    [
        {
            'latitude'     => 66.8309,
            'longitude'    => 20.39919,
            'address'      => 'Norrbotten, Sverige',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)

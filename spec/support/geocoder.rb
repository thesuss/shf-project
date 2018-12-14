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
            'latitude'  => 60.47202399999999,
            'longitude' => 8.468945999999999,
            'address'   => 'Norway',
            'country'   => 'Norway'
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

Geocoder::Lookup::Test.add_stub(

    "Stockholm, Sverige",
    [
        {
            'coordinates' => [59.3251172, 18.0710935],
            'latitude'     => 59.3251172,
            'longitude'    => 18.0710935,
            'address'      => 'Stockholm, Sverige',
            'city'         => 'Stockholm',
            'country'      => 'Sverige',
            'country_code' => 'se'
        }
    ]
)

Geocoder::Lookup::Test.add_stub(

    "Seattle, United States",
    [
        {
            'coordinates' => [47.6038321, -122.3300624],
            'latitude'     => 47.6038321,
            'longitude'    => -122.3300624,
            'address'      => 'Seattle, WA, USA',
            'city'         => 'Seattle',
            'country'      => 'United States of America',
            'country_code' => 'us'
        }
    ]
)

Geocoder::Lookup::Test.add_stub(

    "Celsiusgatan 6, 112 30, Stockholm, Ale, Sverige",
    [
        {
            'latitude'     => 59.3329232,
            'longitude'    => 18.0392789,
            'address'      => 'Celsiusgatan 6, 112 30, Stockholm, Ale, Sverige',
            'city'         => 'Stockholm',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)

Geocoder::Lookup::Test.add_stub(

    "Rehnsgatan 15, 113 57, Stockholm, Ale, Sverige",
    [
        {
            'latitude'     => 59.342636,
            'longitude'    => 18.0594449,
            'address'      => 'Rehnsgatan 15, 113 57, Stockholm, Ale, Sverige',
            'city'         => 'Stockholm',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)

Geocoder::Lookup::Test.add_stub(

    "Bodalsvägen 15, 181 36, Lidingö, Ale, Sverige",
    [
        {
            'latitude'     => 59.3498151,
            'longitude'    => 18.1398528,
            'address'      => 'Bodalsvägen 15, 181 36, Lidingö, Ale, Sverige',
            'city'         => 'Stockholm',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)

Geocoder::Lookup::Test.add_stub(

    "Ulvsundavägen 146, 167 68, Bromma, Ale, Sverige",
    [
        {
            'latitude'     => 59.3414953,
            'longitude'    => 17.9613089,
            'address'      => 'Ulvsundavägen 146, 167 68, Bromma, Ale, Sverige',
            'city'         => 'Stockholm',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)

Geocoder::Lookup::Test.add_stub(

    "Svärdlångsvägen 11 C, 120 60, Årsta, Ale, Sverige",
    [
        {
            'latitude'     => 59.3012505,
            'longitude'    => 18.0349363,
            'address'      => 'Svärdlångsvägen 11 C, 120 60, Årsta, Ale, Sverige',
            'city'         => 'Stockholm',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)

Geocoder::Lookup::Test.add_stub(

    "AKALLALÄNKEN 10, 164 74, Kista, Ale, Sverige",
    [
        {
            'latitude'     => 59.4166931,
            'longitude'    => 17.905791,
            'address'      => 'AKALLALÄNKEN 10, 164 74, Kista, Ale, Sverige',
            'city'         => 'Stockholm',
            'country'      => 'Sverige',
            'country_code' => 'SE'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(

    "3718 Bagley Ave N, Seattle WA 98103, United States",
    [
        {
            'latitude'     => 47.6525371,
            'longitude'    => -122.33234885560,
            'address'      => '3718 Bagley Ave N, Seattle WA 98103, United States',
            'city'         => 'Seattle',
            'country'      => 'United States',
            'country_code' => 'us'
        }
    ]
)


Geocoder::Lookup::Test.add_stub(
  "P.O. Box 3909,98382,Sequim,United States",
  [
      {
          'latitude'     => 48.0849312,
          'longitude'    => -123.1096706,
          'address'      => 'P.O. Box 3909,Sequim,WA 98382,United States',
          'city'         => 'Seattle',
          'country'      => 'United States',
          'country_code' => 'us'
      }
  ]
)

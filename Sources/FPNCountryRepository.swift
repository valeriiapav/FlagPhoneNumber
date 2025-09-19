//
//  FPNCountryRepository.swift
//  FlagPhoneNumber
//
//  Created by Aurelien on 21/11/2019.
//

import Foundation

open class FPNCountryRepository {

	open var locale: Locale
	open var countries: [FPNCountry] = []

	public init(locale: Locale = Locale.current) {
		self.locale = locale
		
		countries = getAllCountries()
	}

	// Populates the metadata from the included json file resource
	private func getAllCountries() -> [FPNCountry] {
	    // Use the correct bundle in both worlds
	    #if SWIFT_PACKAGE
	    let bundle = Bundle.module
	    #else
	    let bundle = Bundle.FlagPhoneNumber()
	    #endif
	
	    guard let url = bundle.url(forResource: "countryCodes", withExtension: "json"),
	          let jsonData = try? Data(contentsOf: url) else {
	        assertionFailure("countryCodes.json not found or unreadable in bundle: \(bundle.bundleURL)")
	        return []
	    }
	
	    var countries: [FPNCountry] = []
	
	    do {
	        if let arr = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
	            for obj in arr {
	                guard let code = obj["code"] as? String,
	                      let phoneCode = obj["dial_code"] as? String,
	                      let name = obj["name"] as? String else { continue }
	                let country = FPNCountry(
	                    code: code,
	                    name: locale.localizedString(forRegionCode: code) ?? name,
	                    phoneCode: phoneCode
	                )
	                countries.append(country)
	            }
	        }
	    } catch {
	        assertionFailure(error.localizedDescription)
	    }
	
	    return countries.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
	}


	private func getAllCountries(excluding countryCodes: [FPNCountryCode]) -> [FPNCountry] {
		var allCountries = getAllCountries()

		for countryCode in countryCodes {
			allCountries.removeAll(where: { (country: FPNCountry) -> Bool in
				return country.code == countryCode
			})
		}
		return allCountries
	}

	private func getAllCountries(equalTo countryCodes: [FPNCountryCode]) -> [FPNCountry] {
		let allCountries = getAllCountries()
		var countries = [FPNCountry]()

		for countryCode in countryCodes {
			for country in allCountries {
				if country.code == countryCode {
					countries.append(country)
				}
			}
		}
		return countries
	}

	open func setup(with countryCodes: [FPNCountryCode]) {
		countries = getAllCountries(equalTo: countryCodes)
	}

	open func setup(without countryCodes: [FPNCountryCode]) {
		countries = getAllCountries(excluding: countryCodes)
	}

}

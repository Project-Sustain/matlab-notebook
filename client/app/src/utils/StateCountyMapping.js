import {countyGIS} from "./gis_county";

export const stateArray = [
    "Alaska",
    "Alabama",
    "Arkansas",
    "Arizona",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "Florida",
    "Georgia",
    "Hawaii",
    "Iowa",
    "Idaho",
    "Illinois",
    "Indiana",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Massachusetts",
    "Maryland",
    "Maine",
    "Michigan",
    "Minnesota",
    "Missouri",
    "Mississippi",
    "Montana",
    "North Carolina",
    "North Dakota",
    "Nebraska",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "Nevada",
    "New York",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Virginia",
    "Vermont",
    "Washington",
    "Wisconsin",
    "West Virginia",
    "Wyoming",
]

function buildData() {
    let data = {};
    stateArray.forEach((state) => {
        data[`${state}`] = {
            counties: []
        };
    });
    const finalData = addCounties(data);
    return finalData;
}

function addCounties(stateArray) {
    let masterMap = {...stateArray};
    countyGIS.forEach((county) => {
        const nameAsArray = county.name.split(" ");
        const names = extractStateCountyName(nameAsArray)
        const stateName = names[0];
        if(Object.keys(masterMap).includes(stateName)) {
            const countyName = names[1];
            masterMap[stateName].counties.push(countyName);
        }
    });
    return masterMap;
}

function findTheComma(nameAsArray) {
    let spot = 0;
    nameAsArray.forEach((word, index) => {
        if(word.charAt(word.length-1) === ",") {
            spot = index+1;
        }
    })
    return spot;
}

function extractStateCountyName(nameAsArray) {
    const indexOfStateName = findTheComma(nameAsArray);
    if(indexOfStateName !== 0) {
        const stateName = nameAsArray.splice(indexOfStateName, nameAsArray.length-1).join(" ");
        let tempCountyName = nameAsArray.splice(0, indexOfStateName).join(" ");
        const countyName = tempCountyName.substr(0, tempCountyName.length-1);
        return [stateName, countyName];
    }
    return ["", ""];
}

export const countyMap = buildData();

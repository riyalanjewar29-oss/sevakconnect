package com.example.data.model

enum class UserRole {
    VOLUNTEER,
    ADMINISTRATIVE,
    DINDI_LEADER
}

data class UserProfile(
    val name: String = "Sevak",
    val mobileNumber: String = "",
    val role: UserRole = UserRole.VOLUNTEER,
    val adminDepartment: String = "",
    val affiliation: String = "Varkari Group",
    val dindiNumber: String = "Dindi #42",
    val isOnline: Boolean = true
)

enum class CrowdSeverity {
    NORMAL,
    MODERATE,
    HIGH,
    CRITICAL
}

data class CrowdReportItem(
    val id: String,
    val zone: String,
    val locationName: String,
    val severity: CrowdSeverity,
    val observations: List<String>,
    val notes: String,
    val timestamp: String,
    val isSynced: Boolean = true
)

data class ZoneStatus(
    val id: String,
    val code: String,
    val name: String,
    val severity: CrowdSeverity,
    val timeAgo: String,
    val hasWarningIcon: Boolean = false,
    val hasBlockIcon: Boolean = false
)

data class MissingPersonItem(
    val id: String,
    val name: String,
    val age: Int,
    val isMinor: Boolean,
    val status: MissingStatus,
    val reportedTime: String,
    val location: String,
    val imageRes: Int? = null,
    val clothingTags: List<String> = emptyList(),
    val notes: String = ""
)

enum class MissingStatus {
    CRITICAL,
    SEARCHING,
    PENDING_MATCH
}

data class SupplyState(
    val isSurplus: Boolean = true,
    val mealsCount: Int = 150,
    val waterLiters: Int = 500,
    val lastBroadcast: String = "Just now"
)

data class NearbyCampMatch(
    val id: String,
    val campName: String,
    val distance: String,
    val needType: String,
    val updatedTime: String
)

data class FacilityItem(
    val id: String,
    val name: String,
    val type: FacilityType,
    val locationName: String,
    val distance: String,
    val status: FacilityStatus,
    val lastUpdated: String
)

enum class FacilityType {
    ALL,
    MEDICAL,
    WATER,
    TOILET
}

enum class FacilityStatus {
    ACTIVE,
    EMPTY,
    FULL
}

data class ChatMessage(
    val id: String,
    val senderName: String,
    val senderDindi: String,
    val message: String,
    val time: String,
    val isSystemAlert: Boolean = false,
    val isHighPriority: Boolean = false,
    val isSelf: Boolean = false,
    val category: String = "General"
)

data class DindiMember(
    val name: String,
    val age: Int,
    val gender: String,
    val mobile: String,
    val emergencyContact: String,
    val assistance: String = "None"
)

data class DindiRegistrationForm(
    val dindiName: String = "Sant Dnyaneshwar Maharaj Dindi",
    val regId: String = "DND-2023-458",
    val leaderName: String = "Pandurang Patil",
    val mobileNumber: String = "+91 98765 43210",
    val memberEstimate: String = "200",
    val arrivalZone: String = "Zone A (North)",
    val expectedArrival: String = "2026-08-30T14:30",
    val category: String = "Alandi",
    val members: List<DindiMember> = listOf(
        DindiMember("Rameshwar Shinde", 45, "Male", "+91 98220 11223", "+91 98220 11224"),
        DindiMember("Sunita Shinde", 42, "Female", "+91 98220 11225", "+91 98220 11224")
    )
)

data class SosAlertState(
    val isTriggered: Boolean = false,
    val locationName: String = "Sector 4, Near Main Temple Gate",
    val coordinates: String = "Lat: 18.5204, Lng: 73.8567",
    val isQueued: Boolean = false,
    val isRelayed: Boolean = false,
    val isDelivered: Boolean = false,
    val timestamp: String = "Just now"
)

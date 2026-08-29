package com.example.data.repository

import com.example.R
import com.example.data.model.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class SevakRepository {
    private val scope = CoroutineScope(Dispatchers.Main)

    // User profile state
    private val _userProfile = MutableStateFlow(
        UserProfile(
            name = "Sevak Name",
            role = UserRole.VOLUNTEER,
            affiliation = "Varkari Group",
            dindiNumber = "Dindi #42",
            isOnline = true
        )
    )
    val userProfile: StateFlow<UserProfile> = _userProfile.asStateFlow()

    // Offline / Online Status
    private val _isOnline = MutableStateFlow(true)
    val isOnline: StateFlow<Boolean> = _isOnline.asStateFlow()

    // Chandrabhaga Zones state
    private val _zones = MutableStateFlow(
        listOf(
            ZoneStatus("1", "Zone 1A", "Main Ghat Entrance", CrowdSeverity.HIGH, "1m ago"),
            ZoneStatus("2", "Zone 2B", "Bridge Crossing", CrowdSeverity.CRITICAL, "Just now", hasBlockIcon = true),
            ZoneStatus("3", "Zone 3C", "South Perimeter", CrowdSeverity.MODERATE, "5m ago"),
            ZoneStatus("4", "Zone 4D", "Parking Area", CrowdSeverity.NORMAL, "10m ago"),
            ZoneStatus("5", "Zone 1B", "Temple Steps", CrowdSeverity.HIGH, "2m ago", hasWarningIcon = true),
            ZoneStatus("6", "Zone 5E", "Rest Camp", CrowdSeverity.NORMAL, "15m ago")
        )
    )
    val zones: StateFlow<List<ZoneStatus>> = _zones.asStateFlow()

    // Active Missing Person Cases
    private val _missingCases = MutableStateFlow(
        listOf(
            MissingPersonItem(
                id = "1",
                name = "Ramesh Patil",
                age = 68,
                isMinor = false,
                status = MissingStatus.CRITICAL,
                reportedTime = "Reported 22m ago near Gate 3",
                location = "Gate 3, Vitthal Temple",
                imageRes = R.drawable.img_missing_elderly,
                clothingTags = listOf("White", "Cotton", "Barefoot"),
                notes = "Carrying a brass Tulsi bead pouch, mild hearing impairment."
            ),
            MissingPersonItem(
                id = "2",
                name = "Aarav Sharma",
                age = 8,
                isMinor = true,
                status = MissingStatus.SEARCHING,
                reportedTime = "Reported 1h 15m ago",
                location = "Main Temple Chowk",
                imageRes = R.drawable.img_missing_child,
                clothingTags = listOf("Yellow", "Cotton"),
                notes = "Separated from parents near the sweet stall."
            ),
            MissingPersonItem(
                id = "3",
                name = "Unknown Female",
                age = 38,
                isMinor = false,
                status = MissingStatus.PENDING_MATCH,
                reportedTime = "Found 45m ago at Main Temple",
                location = "Holding Area B",
                imageRes = null,
                clothingTags = listOf("Saffron", "Cotton"),
                notes = "Found disoriented, resting safely at Sevak desk."
            )
        )
    )
    val missingCases: StateFlow<List<MissingPersonItem>> = _missingCases.asStateFlow()

    // Camp Supplies State
    private val _supplies = MutableStateFlow(SupplyState(isSurplus = true, mealsCount = 150, waterLiters = 500))
    val supplies: StateFlow<SupplyState> = _supplies.asStateFlow()

    private val _nearbyMatches = MutableStateFlow(
        listOf(
            NearbyCampMatch("1", "Camp Dindi #18", "0.8 km away", "Needs Water", "Updated 5m ago"),
            NearbyCampMatch("2", "Camp Varkari East", "1.2 km away", "Needs Meals", "Updated 12m ago")
        )
    )
    val nearbyMatches: StateFlow<List<NearbyCampMatch>> = _nearbyMatches.asStateFlow()

    // Facilities State
    private val _facilities = MutableStateFlow(
        listOf(
            FacilityItem("1", "Base Camp Med Station", FacilityType.MEDICAL, "Near North Gate", "1.2 km", FacilityStatus.ACTIVE, "Active"),
            FacilityItem("2", "Water Point Alpha", FacilityType.WATER, "Route 4 Intersection", "0.5 km", FacilityStatus.EMPTY, "Updated 10m ago"),
            FacilityItem("3", "Mobile Toilet Cluster D", FacilityType.TOILET, "South Ghat Boundary", "0.9 km", FacilityStatus.ACTIVE, "Updated 3m ago"),
            FacilityItem("4", "Emergency Response Tent #2", FacilityType.MEDICAL, "Temple West Outer", "0.3 km", FacilityStatus.ACTIVE, "Active"),
            FacilityItem("5", "River Bank Water Cistern 500L", FacilityType.WATER, "Chandrabhaga Steps", "0.4 km", FacilityStatus.ACTIVE, "Updated 1m ago")
        )
    )
    val facilities: StateFlow<List<FacilityItem>> = _facilities.asStateFlow()

    // Chat Messages
    private val _chatMessages = MutableStateFlow(
        listOf(
            ChatMessage("1", "Rahul Patil", "Dindi #12", "Water station 3 is running low. Requesting refill vehicle dispatch.", "10:42 AM", category = "General"),
            ChatMessage("2", "SYSTEM ALERT", "", "Crowd surge detected near main temple gate. All available volunteers please redirect to zone A immediately.", "10:45 AM", isSystemAlert = true, isHighPriority = true, category = "General"),
            ChatMessage("3", "You", "Dindi #42", "Copy that. Heading to zone A now.", "10:48 AM", isSelf = true, category = "General"),
            ChatMessage("4", "Amit Kumar", "Dindi #4", "Arrived at zone A. Assisting with crowd flow management.", "10:50 AM", category = "General"),
            ChatMessage("5", "Dr. Kulkarni", "Medical Corps", "Medical tent 1 has oxygen cylinders and ORS sachets available.", "10:52 AM", category = "Medical Escalation"),
            ChatMessage("6", "Insp. Gaikwad", "Police Liaison", "Heavy vehicle movement restricted around Wakhari until 17:00 HRS.", "10:55 AM", category = "Police Liaison")
        )
    )
    val chatMessages: StateFlow<List<ChatMessage>> = _chatMessages.asStateFlow()

    // Registration State
    private val _dindiForm = MutableStateFlow(DindiRegistrationForm())
    val dindiForm: StateFlow<DindiRegistrationForm> = _dindiForm.asStateFlow()

    // SOS State
    private val _sosState = MutableStateFlow(SosAlertState())
    val sosState: StateFlow<SosAlertState> = _sosState.asStateFlow()

    fun toggleOnlineStatus() {
        _isOnline.value = !_isOnline.value
        _userProfile.value = _userProfile.value.copy(isOnline = _isOnline.value)
    }

    fun setUserLoginInfo(name: String, mobileNumber: String) {
        _userProfile.value = _userProfile.value.copy(
            name = if (name.isNotBlank()) name else _userProfile.value.name,
            mobileNumber = mobileNumber
        )
    }

    fun updateUserRole(role: UserRole, affiliation: String, adminDepartment: String = "") {
        _userProfile.value = _userProfile.value.copy(
            role = role,
            affiliation = affiliation,
            adminDepartment = adminDepartment
        )
    }

    fun updateSupplyState(isSurplus: Boolean, mealsCount: Int, waterLiters: Int) {
        _supplies.value = SupplyState(isSurplus = isSurplus, mealsCount = mealsCount, waterLiters = waterLiters, lastBroadcast = "Just now")
    }

    fun addMissingPerson(person: MissingPersonItem) {
        _missingCases.value = listOf(person) + _missingCases.value
    }

    fun sendChatMessage(text: String, category: String = "General") {
        if (text.isBlank()) return
        val newMsg = ChatMessage(
            id = System.currentTimeMillis().toString(),
            senderName = "You",
            senderDindi = _userProfile.value.dindiNumber,
            message = text,
            time = "Just now",
            isSelf = true,
            category = category
        )
        _chatMessages.value = _chatMessages.value + newMsg
    }

    fun addDindiMember(member: DindiMember) {
        val current = _dindiForm.value
        _dindiForm.value = current.copy(members = current.members + member)
    }

    fun triggerSosAlert() {
        _sosState.value = SosAlertState(isTriggered = true, isQueued = true, isRelayed = false, isDelivered = false)
        scope.launch {
            delay(400)
            _sosState.value = _sosState.value.copy(isQueued = true)
            delay(700)
            _sosState.value = _sosState.value.copy(isRelayed = true)
            delay(800)
            _sosState.value = _sosState.value.copy(isDelivered = true)
        }
    }

    fun resetSosAlert() {
        _sosState.value = SosAlertState()
    }
}

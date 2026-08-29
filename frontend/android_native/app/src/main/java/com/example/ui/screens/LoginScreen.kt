package com.example.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.CheckCircle
import androidx.compose.material.icons.outlined.Security
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.data.repository.SevakRepository
import com.example.ui.theme.*

@Composable
fun LoginScreen(
    repository: SevakRepository,
    onProceedToOtp: (name: String, mobile: String) -> Unit,
    modifier: Modifier = Modifier
) {
    var fullName by remember { mutableStateOf("") }
    var mobileNumber by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    val focusManager = LocalFocusManager.current

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(SurfaceColor)
    ) {
        // Background decorative elements
        Image(
            painter = painterResource(id = R.drawable.img_pandharpur_splash),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        // Soft gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.White.copy(alpha = 0.92f),
                            Color.White.copy(alpha = 0.88f),
                            Color.White.copy(alpha = 0.96f)
                        )
                    )
                )
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(24.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Top Section: Logo & Branding
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth()
            ) {
                Spacer(modifier = Modifier.height(12.dp))

                // Unified App Logo Frame (integrated seamlessly)
                Box(
                    modifier = Modifier
                        .size(108.dp)
                        .clip(CircleShape)
                        .background(Color.White)
                        .border(2.dp, PrimaryContainerColor.copy(alpha = 0.4f), CircleShape)
                        .padding(10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.ic_sevak_logo_1788005512622),
                        contentDescription = "SevakConnect Logo",
                        contentScale = ContentScale.Fit,
                        modifier = Modifier
                            .fillMaxSize()
                            .testTag("login_brand_logo")
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                Text(
                    text = "SEVAKCONNECT",
                    style = MaterialTheme.typography.headlineLarge.copy(
                        fontWeight = FontWeight.Black,
                        color = Color(0xFF1E293B),
                        letterSpacing = 1.2.sp
                    ),
                    textAlign = TextAlign.Center
                )

                Text(
                    text = "Pandharpur Wari Seva Coordination",
                    style = MaterialTheme.typography.bodyMedium.copy(
                        color = PrimaryColor,
                        fontWeight = FontWeight.SemiBold
                    ),
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(24.dp))

                // Card with Input Fields
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = Color.White,
                    shadowElevation = 3.dp,
                    border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor.copy(alpha = 0.8f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Text(
                            text = "Login / नोंदणी",
                            style = MaterialTheme.typography.titleLarge.copy(
                                fontWeight = FontWeight.Bold,
                                color = OnSurfaceColor
                            )
                        )

                        Text(
                            text = "Enter your details to coordinate and stay connected with Wari seva teams.",
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = OnSurfaceVariantColor
                            )
                        )

                        HorizontalDivider(color = SurfaceVariantColor)

                        // Full Name Input
                        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                            Text(
                                text = "Full Name / पूर्ण नाव",
                                style = MaterialTheme.typography.labelMedium.copy(
                                    fontWeight = FontWeight.SemiBold,
                                    color = OnSurfaceColor
                                )
                            )

                            OutlinedTextField(
                                value = fullName,
                                onValueChange = {
                                    fullName = it
                                    errorMessage = null
                                },
                                placeholder = { Text("e.g. Rameshwar Patil") },
                                leadingIcon = {
                                    Icon(
                                        imageVector = Icons.Default.Person,
                                        contentDescription = null,
                                        tint = PrimaryColor
                                    )
                                },
                                singleLine = true,
                                shape = RoundedCornerShape(12.dp),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = PrimaryColor,
                                    unfocusedBorderColor = OutlineColor,
                                    focusedContainerColor = Color.White,
                                    unfocusedContainerColor = Color.White
                                ),
                                keyboardOptions = KeyboardOptions(
                                    keyboardType = KeyboardType.Text,
                                    imeAction = ImeAction.Next
                                ),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .testTag("login_name_input")
                            )
                        }

                        // Mobile Number Input
                        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                            Text(
                                text = "Mobile Number / मोबाइल क्रमांक",
                                style = MaterialTheme.typography.labelMedium.copy(
                                    fontWeight = FontWeight.SemiBold,
                                    color = OnSurfaceColor
                                )
                            )

                            OutlinedTextField(
                                value = mobileNumber,
                                onValueChange = { input ->
                                    val digitsOnly = input.filter { it.isDigit() }.take(10)
                                    mobileNumber = digitsOnly
                                    errorMessage = null
                                },
                                placeholder = { Text("98XXXXXXXX") },
                                leadingIcon = {
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        modifier = Modifier.padding(start = 12.dp, end = 6.dp)
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.Phone,
                                            contentDescription = null,
                                            tint = PrimaryColor,
                                            modifier = Modifier.size(20.dp)
                                        )
                                        Spacer(modifier = Modifier.width(4.dp))
                                        Text(
                                            text = "+91",
                                            style = MaterialTheme.typography.bodyMedium.copy(
                                                fontWeight = FontWeight.Bold,
                                                color = OnSurfaceColor
                                            )
                                        )
                                        Spacer(modifier = Modifier.width(4.dp))
                                        Box(
                                            modifier = Modifier
                                                .width(1.dp)
                                                .height(20.dp)
                                                .background(OutlineColor)
                                        )
                                    }
                                },
                                singleLine = true,
                                shape = RoundedCornerShape(12.dp),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = PrimaryColor,
                                    unfocusedBorderColor = OutlineColor,
                                    focusedContainerColor = Color.White,
                                    unfocusedContainerColor = Color.White
                                ),
                                keyboardOptions = KeyboardOptions(
                                    keyboardType = KeyboardType.Phone,
                                    imeAction = ImeAction.Done
                                ),
                                keyboardActions = KeyboardActions(
                                    onDone = { focusManager.clearFocus() }
                                ),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .testTag("login_phone_input")
                            )
                        }

                        // Error message if validation fails
                        if (errorMessage != null) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp),
                                modifier = Modifier.padding(top = 2.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.ErrorOutline,
                                    contentDescription = null,
                                    tint = ErrorColor,
                                    modifier = Modifier.size(16.dp)
                                )
                                Text(
                                    text = errorMessage!!,
                                    style = MaterialTheme.typography.bodySmall.copy(
                                        color = ErrorColor,
                                        fontWeight = FontWeight.Medium
                                    )
                                )
                            }
                        }

                        // Quick demo helper pill
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = PrimaryContainerColor.copy(alpha = 0.25f),
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    fullName = "Anand Deshmukh"
                                    mobileNumber = "9822145890"
                                    errorMessage = null
                                }
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Outlined.CheckCircle,
                                        contentDescription = null,
                                        tint = PrimaryColor,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Text(
                                        text = "Auto-fill demo test credentials",
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            color = OnSurfaceColor,
                                            fontWeight = FontWeight.Medium
                                        )
                                    )
                                }
                                Text(
                                    text = "Tap here",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = PrimaryColor,
                                        fontWeight = FontWeight.Bold
                                    )
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Bottom CTA Button & Security info
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.padding(bottom = 12.dp)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Security,
                        contentDescription = null,
                        tint = OnSurfaceVariantColor,
                        modifier = Modifier.size(16.dp)
                    )
                    Text(
                        text = "Encrypted OTP verification for authorized Seva safety",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnSurfaceVariantColor,
                            fontSize = 12.sp
                        )
                    )
                }

                Button(
                    onClick = {
                        if (fullName.trim().isEmpty()) {
                            errorMessage = "Please enter your name"
                            return@Button
                        }
                        if (mobileNumber.length < 10) {
                            errorMessage = "Please enter a valid 10-digit mobile number"
                            return@Button
                        }
                        errorMessage = null
                        repository.setUserLoginInfo(fullName.trim(), mobileNumber)
                        onProceedToOtp(fullName.trim(), mobileNumber)
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = PrimaryColor,
                        contentColor = OnPrimaryColor
                    ),
                    shape = RoundedCornerShape(999.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp)
                        .testTag("login_submit_button")
                ) {
                    Text(
                        text = "Get OTP Verification Code",
                        style = MaterialTheme.typography.labelLarge.copy(
                            fontWeight = FontWeight.Bold,
                            fontSize = 16.sp
                        )
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }
    }
}

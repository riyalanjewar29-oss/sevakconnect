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
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.CheckCircle
import androidx.compose.material.icons.outlined.Edit
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
import kotlinx.coroutines.delay

@Composable
fun OtpVerificationScreen(
    repository: SevakRepository,
    name: String,
    mobile: String,
    onVerified: () -> Unit,
    onBackToLogin: () -> Unit,
    modifier: Modifier = Modifier
) {
    var otpCode by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var resendTimer by remember { mutableStateOf(30) }
    var isTimerActive by remember { mutableStateOf(true) }
    val focusManager = LocalFocusManager.current

    LaunchedEffect(isTimerActive, resendTimer) {
        if (isTimerActive && resendTimer > 0) {
            delay(1000)
            resendTimer -= 1
        } else if (resendTimer == 0) {
            isTimerActive = false
        }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(SurfaceColor)
    ) {
        Image(
            painter = painterResource(id = R.drawable.img_pandharpur_splash),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

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
            // Top Bar with Back Button
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(
                    onClick = onBackToLogin,
                    modifier = Modifier
                        .size(40.dp)
                        .testTag("otp_back_button")
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Back",
                        tint = OnSurfaceColor
                    )
                }
                Spacer(modifier = Modifier.weight(1f))
            }

            // Main Content Area
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth()
            ) {
                // Integrated Brand Logo
                Box(
                    modifier = Modifier
                        .size(96.dp)
                        .clip(CircleShape)
                        .background(Color.White)
                        .border(2.dp, PrimaryContainerColor.copy(alpha = 0.4f), CircleShape)
                        .padding(8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.ic_sevak_logo_1788005512622),
                        contentDescription = "SevakConnect Logo",
                        contentScale = ContentScale.Fit,
                        modifier = Modifier.fillMaxSize()
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "OTP Verification",
                    style = MaterialTheme.typography.displayLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = OnSurfaceColor,
                        fontSize = 28.sp
                    ),
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "Enter the 4-digit OTP sent to",
                    style = MaterialTheme.typography.bodyMedium.copy(
                        color = OnSurfaceVariantColor
                    ),
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(4.dp))

                // Mobile number pill with edit option
                Surface(
                    shape = RoundedCornerShape(999.dp),
                    color = PrimaryContainerColor.copy(alpha = 0.3f),
                    modifier = Modifier.clickable { onBackToLogin() }
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Text(
                            text = "+91 ${mobile.ifEmpty { "9876543210" }}",
                            style = MaterialTheme.typography.labelLarge.copy(
                                color = PrimaryColor,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Icon(
                            imageVector = Icons.Outlined.Edit,
                            contentDescription = "Edit phone number",
                            tint = PrimaryColor,
                            modifier = Modifier.size(14.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(28.dp))

                // OTP Card
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = Color.White,
                    shadowElevation = 3.dp,
                    border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor.copy(alpha = 0.8f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(18.dp)
                    ) {
                        // 4-Digit Boxes Representation
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(10.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            for (i in 0 until 4) {
                                val char = otpCode.getOrNull(i)?.toString() ?: ""
                                val isCurrent = otpCode.length == i || (otpCode.length == 4 && i == 3)
                                Box(
                                    modifier = Modifier
                                        .size(54.dp)
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(if (char.isNotEmpty()) PrimaryContainerColor.copy(alpha = 0.2f) else SurfaceContainer)
                                        .border(
                                            width = if (isCurrent) 2.dp else 1.dp,
                                            color = if (isCurrent) PrimaryColor else OutlineColor.copy(alpha = 0.5f),
                                            shape = RoundedCornerShape(12.dp)
                                        ),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = char,
                                        style = MaterialTheme.typography.headlineLarge.copy(
                                            fontWeight = FontWeight.Bold,
                                            color = PrimaryColor,
                                            fontSize = 24.sp
                                        )
                                    )
                                }
                            }
                        }

                        // Actual hidden/styled input field
                        OutlinedTextField(
                            value = otpCode,
                            onValueChange = { input ->
                                val digits = input.filter { it.isDigit() }.take(4)
                                otpCode = digits
                                errorMessage = null
                            },
                            placeholder = { Text("Enter 4-digit OTP", textAlign = TextAlign.Center) },
                            singleLine = true,
                            shape = RoundedCornerShape(12.dp),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = PrimaryColor,
                                unfocusedBorderColor = OutlineColor
                            ),
                            keyboardOptions = KeyboardOptions(
                                keyboardType = KeyboardType.NumberPassword,
                                imeAction = ImeAction.Done
                            ),
                            keyboardActions = KeyboardActions(
                                onDone = { focusManager.clearFocus() }
                            ),
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("otp_input_field")
                        )

                        if (errorMessage != null) {
                            Text(
                                text = errorMessage!!,
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = ErrorColor,
                                    fontWeight = FontWeight.Medium
                                ),
                                textAlign = TextAlign.Center
                            )
                        }

                        // Quick Fill Demo Hint
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = SurfaceContainerHighest,
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    otpCode = "2026"
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
                                        tint = SecondaryColor,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Text(
                                        text = "Test Code: 2026",
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            color = OnSurfaceColor,
                                            fontWeight = FontWeight.SemiBold
                                        )
                                    )
                                }
                                Text(
                                    text = "Auto-fill",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = SecondaryColor,
                                        fontWeight = FontWeight.Bold
                                    )
                                )
                            }
                        }

                        // Resend Section
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            if (isTimerActive) {
                                Text(
                                    text = "Resend OTP in ${resendTimer}s",
                                    style = MaterialTheme.typography.bodySmall.copy(
                                        color = OnSurfaceVariantColor
                                    )
                                )
                            } else {
                                TextButton(
                                    onClick = {
                                        resendTimer = 30
                                        isTimerActive = true
                                        errorMessage = null
                                    }
                                ) {
                                    Text(
                                        text = "Resend OTP Code",
                                        style = MaterialTheme.typography.labelMedium.copy(
                                            color = PrimaryColor,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Verify Button
            Button(
                onClick = {
                    if (otpCode.length < 4) {
                        errorMessage = "Please enter complete 4-digit code"
                        return@Button
                    }
                    errorMessage = null
                    onVerified()
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = PrimaryColor,
                    contentColor = OnPrimaryColor
                ),
                shape = RoundedCornerShape(999.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(54.dp)
                    .testTag("verify_otp_button")
            ) {
                Text(
                    text = "Verify & Proceed",
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

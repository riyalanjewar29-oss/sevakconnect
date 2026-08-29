package com.example

import com.example.data.model.BackendResponse
import retrofit2.http.GET

interface ApiService {

    @GET("/")
    suspend fun checkBackend(): BackendResponse
}
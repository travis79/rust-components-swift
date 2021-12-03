// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

#pragma once

#include <stdbool.h>
#include <stdint.h>

// The following structs are used to implement the lowest level
// of the FFI, and thus useful to multiple uniffied crates.
// We ensure they are declared exactly once, with a header guard, UNIFFI_SHARED_H.
#ifdef UNIFFI_SHARED_H
    // We also try to prevent mixing versions of shared uniffi header structs.
    // If you add anything to the #else block, you must increment the version suffix in UNIFFI_SHARED_HEADER_V3
    #ifndef UNIFFI_SHARED_HEADER_V3
        #error Combining helper code from multiple versions of uniffi is not supported
    #endif // ndef UNIFFI_SHARED_HEADER_V3
#else
#define UNIFFI_SHARED_H
#define UNIFFI_SHARED_HEADER_V3
// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V3 in this file.           ⚠️

typedef struct RustBuffer
{
    int32_t capacity;
    int32_t len;
    uint8_t *_Nullable data;
} RustBuffer;

typedef RustBuffer (*ForeignCallback)(uint64_t, int32_t, RustBuffer);

typedef struct ForeignBytes
{
    int32_t len;
    const uint8_t *_Nullable data;
} ForeignBytes;

// Error definitions
typedef struct RustCallStatus {
    int8_t code;
    RustBuffer errorBuf;
} RustCallStatus;

// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V3 in this file.           ⚠️
#endif // def UNIFFI_SHARED_H

void ffi_fxa_client_9b3e_FirefoxAccount_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull fxa_client_9b3e_FirefoxAccount_new(
      RustBuffer content_url,RustBuffer client_id,RustBuffer redirect_uri,RustBuffer token_server_url_override,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull fxa_client_9b3e_FirefoxAccount_from_json(
      RustBuffer data,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_to_json(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_begin_oauth_flow(
      void*_Nonnull ptr,RustBuffer scopes,RustBuffer entrypoint,RustBuffer metrics,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_pairing_authority_url(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_begin_pairing_flow(
      void*_Nonnull ptr,RustBuffer pairing_url,RustBuffer scopes,RustBuffer entrypoint,RustBuffer metrics,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_complete_oauth_flow(
      void*_Nonnull ptr,RustBuffer code,RustBuffer state,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_check_authorization_status(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_disconnect(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_profile(
      void*_Nonnull ptr,int8_t ignore_cache,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_initialize_device(
      void*_Nonnull ptr,RustBuffer name,RustBuffer device_type,RustBuffer supported_capabilities,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_current_device_id(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_devices(
      void*_Nonnull ptr,int8_t ignore_cache,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_attached_clients(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_set_device_name(
      void*_Nonnull ptr,RustBuffer display_name,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_clear_device_name(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_ensure_capabilities(
      void*_Nonnull ptr,RustBuffer supported_capabilities,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_set_push_subscription(
      void*_Nonnull ptr,RustBuffer subscription,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_handle_push_message(
      void*_Nonnull ptr,RustBuffer payload,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_poll_device_commands(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_send_single_tab(
      void*_Nonnull ptr,RustBuffer target_device_id,RustBuffer title,RustBuffer url,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_token_server_endpoint_url(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_connection_success_url(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_manage_account_url(
      void*_Nonnull ptr,RustBuffer entrypoint,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_manage_devices_url(
      void*_Nonnull ptr,RustBuffer entrypoint,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_access_token(
      void*_Nonnull ptr,RustBuffer scope,RustBuffer ttl,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_get_session_token(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_handle_session_token_change(
      void*_Nonnull ptr,RustBuffer session_token,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_authorize_code_using_session_token(
      void*_Nonnull ptr,RustBuffer params,
    RustCallStatus *_Nonnull out_status
    );
void fxa_client_9b3e_FirefoxAccount_clear_access_token_cache(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_gather_telemetry(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_migrate_from_session_token(
      void*_Nonnull ptr,RustBuffer session_token,RustBuffer k_sync,RustBuffer k_xcs,int8_t copy_session_token,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_retry_migrate_from_session_token(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer fxa_client_9b3e_FirefoxAccount_is_in_migration_state(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_fxa_client_9b3e_rustbuffer_alloc(
      int32_t size,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_fxa_client_9b3e_rustbuffer_from_bytes(
      ForeignBytes bytes,
    RustCallStatus *_Nonnull out_status
    );
void ffi_fxa_client_9b3e_rustbuffer_free(
      RustBuffer buf,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_fxa_client_9b3e_rustbuffer_reserve(
      RustBuffer buf,int32_t additional,
    RustCallStatus *_Nonnull out_status
    );

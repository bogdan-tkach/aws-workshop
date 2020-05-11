#!/bin/bash

user_name="$1"

echo "Removing user: ${user_name}"

echo "Deleting Access Keys:"
keys=("$(aws2 iam list-access-keys --user-name "${user_name}" | jq -r '.AccessKeyMetadata[] | .AccessKeyId')")
if [[ "${#keys}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for key in ${keys[@]}; do
        echo -e "\tDeleting access key ${key}"
        aws2 iam delete-access-key --user-name "${user_name}" --access-key-id "${key}"
    done
fi

echo "Deleting Signing Certificates:"
certs=("$(aws2 iam list-signing-certificates --user-name "${user_name}" | jq -r '.Certificates[] | .CertificateId')")
if [[ "${#certs}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for cert in ${certs[@]}; do
        echo -e "\tDeleting cert ${cert}"
        aws2 iam delete-signing-certificate --user-name "${user_name}"  --certificate-id "$cert"
    done
fi

echo "Deleting Login Profile"
# shellcheck disable=SC2091
if $(aws2 iam get-login-profile --user-name "${user_name}" &>/dev/null); then
    aws2 iam delete-login-profile --user-name "${user_name}"
fi

echo "Deleting User's 2FA Devices:"
devs=("$(aws2 iam list-mfa-devices --user-name "${user_name}" | jq -r '.MFADevices[] | .SerialNumber')")
if [[ "${#devs}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for mfa_dev in ${devs[@]}; do
        echo -e "\tDeleting MFA ${mfa_dev}"
        aws2 iam deactivate-mfa-device --user-name "${user_name}"  --serial-number "${mfa_dev}"
    done
fi

echo "Removing Attached User Policies:"
pols=("$(aws2 iam list-attached-user-policies --user-name "${user_name}" | jq -r '.AttachedPolicies[] | .PolicyArn')")
if [[ "${#pols}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for policy in ${pols[@]}; do
        echo -e "\tDetaching user policy $(basename "${policy}")"
        aws2 iam detach-user-policy \
        --user-name "${user_name}" \
        --policy-arn "${policy}"
    done
fi

echo "Deleting Inline Policies:"
inline_policies=("$(aws2 iam list-user-policies --user-name "${user_name}" | jq -r '.PolicyNames[]')")

# shellcheck disable=SC2068
for inline_policy in ${inline_policies[@]}; do
    echo -e "\tDeleting inline policy ${inline_policy}"
    aws2 iam delete-user-policy \
        --user-name "${user_name}" \
        --policy-name "${inline_policy}"
done

echo "Removing Group Memberships:"
groups=("$(aws2 iam list-groups-for-user --user-name "${user_name}" | jq -r '.Groups[] | .GroupName')")
# shellcheck disable=SC2068
for group in ${groups[@]}; do
    echo -e "\tRemoving user from group ${group}"
    aws2 iam remove-user-from-group \
        --group-name "${group}" \
        --user-name "${user_name}"
done

echo "Deleting User"
 aws2 iam delete-user --user-name "${user_name}"
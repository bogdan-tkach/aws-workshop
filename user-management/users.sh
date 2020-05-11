#!/bin/bash
#make sure to set up AWS CLI profile
profile_to_use='bogdan_tkach@epam.com'
group_name='Trainees'
user_name=$2

export AWS_PROFILE=$profile_to_use

echo 'using profile '$AWS_PROFILE

function create_user() {
  echo 'creating user '$user_name
  aws iam create-user --user-name $user_name
  aws iam create-login-profile --user-name $user_name --password $user_name --no-password-reset-required
  aws iam add-user-to-group --user-name $user_name --group-name $group_name
}

function delete_user() {

  echo "Removing user: ${user_name}"

  echo "Deleting Access Keys:"
  keys=("$(aws iam list-access-keys --user-name $user_name --query 'AccessKeyMetadata[*].AccessKeyId' --output text)")
  if [[ "${#keys}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for key in ${keys[@]}; do
      echo -e "\tDeleting access key ${key}"
      aws iam delete-access-key --user-name "${user_name}" --access-key-id "${key}"
    done
  fi

  echo "Removing Group Memberships:"
  groups=("$(aws iam list-groups-for-user --user-name "${user_name}" --query 'Groups[*].[GroupName]' --output text)")
  # shellcheck disable=SC2068
  for group in ${groups[@]}; do
    echo -e "\tRemoving user from group ${group}"
    aws iam remove-user-from-group \
    --group-name "${group}" \
    --user-name "${user_name}"
  done

  echo "Deleting User"
  aws iam delete-user --user-name "${user_name}"
}

case "$1" in
'create_user')
  create_user
  ;;
'create_users')
  while IFS= read line
  do
	./users.sh create_user "${line//[$'\t\r\n ']}"
  done <"trainee.list"
  ;;
'delete_user')
  delete_user
  ;;
*)
  echo "Unsupported parameter $1"
  ;;
esac

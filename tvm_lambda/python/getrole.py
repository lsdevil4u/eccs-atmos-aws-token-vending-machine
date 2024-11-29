try: 
    import os
    import argparse
    import base64
    import json
    import logging
    from pprint import pprint
    import time
    import re
    import random
    import smtplib
    from email.message import EmailMessage
    import boto3
    from botocore.exceptions import ClientError
    print("All imports ok ...")
except Exception as e:
    print("Error Imports : {} ".format(e))
    
def lambda_handler(event, context):
    # get the feature flags from the environment to switch on/off capabilities
    feature_enabled = os.getenv('feature_enabled')
    feature_outputlogging = os.getenv('feature_outputlogging')
    feature_inputlogging = os.getenv('feature_inputlogging')

    #print("os.environ : {} ".format(os.environ))
    print("feature_enabled : {} ".format(feature_enabled))
    print("feature_outputlogging : {} ".format(feature_outputlogging))
    print("feature_inputlogging : {} ".format(feature_inputlogging))

    #proxy = 'emea-aws-webproxy.service.cloud.local:3128'
    #noproxy = 'emea-aws-smtp-auth.service.cloud.local'

    #os.environ['http_proxy'] = proxy 
    #os.environ['HTTP_PROXY'] = proxy
    #os.environ['https_proxy'] = proxy
    #os.environ['HTTPS_PROXY'] = proxy
    #os.environ['no_proxy'] = noproxy
    #os.environ['NO_PROXY'] = noproxy

    adminkeystub = 'adminkey_v02'

    if feature_enabled :
        if feature_inputlogging : 
            print("Context : {} ".format(context))
            print("Event : {} ".format(event))
        if event['action'] == 'getrole':
                print("action == getrole")
                token = event.get('token', None)
                rolename = event.get('role', None)
                repo = event.get('repo', None)
                actor = event.get('actor', None)
                wildcardrole = event.get('wildcard', None)
                print("wildcardrole : {} ".format(wildcardrole))
                roleStub = roleArnToRoleStub(rolename, wildcardrole)
                wildroleStub = convertRoleToWildcardStub(rolename)
                externalid=event['externalid']
                # use regexp to check the token length and that its alphanum only
                tokenCheck=re.match('^[0-9a-zA-Z]{64}$', token)
                if tokenCheck==None:
                    print("token does not meet requirements")
                    return 'Error: invalid token.'
                else:
                    print("token meets data type requirements")
                    if len(token) == 64:
                        try:
                            session = boto3.session.Session()
                            SManager = session.client(
                                service_name='secretsmanager',
                                region_name='eu-west-1'
                            )
                            print("token meets validation requirements")
                            # check for the secret named for this token
                            secret = getRoleSecretData(SManager, roleStub)
                            if feature_inputlogging :
                                print("Secret : {} ".format(secret))
                            for value in secret:
                                if feature_inputlogging :
                                    print("checking value: {} ".format(value))
                                    print("checking rolename: {} ".format(rolename))
                                    print("checking wildroleStub: {} ".format(wildroleStub))
                                    print("checking value: {} ".format(secret[value]))
                                if (value == rolename and secret[value] == token) or (value == wildroleStub and secret[value] == token and wildcardrole == 'true'):
                                    print("Matched Role and Token")
                                    try:
                                        #assume the role
                                        sts_connection = boto3.client('sts')
                                        acct_b = sts_connection.assume_role(
                                            RoleArn=rolename,
                                            RoleSessionName="cross_acct_lambda",
                                            ExternalId=externalid
                                        )
                                        if feature_outputlogging == 1: 
                                            print("IAM Assume Role Response : {} ".format(json.dumps(acct_b['Credentials'], default=str)))
                                        return json.dumps(acct_b['Credentials'], default=str)
                                    except ClientError as e:
                                        print("Error: {} ".format(e))
                                        return "Error : {} ".format(e)
                        except ClientError as e:
                            return "Role assume error: {} ".format(e)
        if event['action'] == 'addrole':
            try:
                session = boto3.session.Session()
                SManager = session.client(
                    service_name='secretsmanager',
                    region_name='eu-west-1'
                )
                print("action == addrole")
                rolename = event['role']
                email = event.get('email', None)
                adminkey = event.get('adminkey', None)
                wildcardrole = event.get('wildcard', None)
                emailcheck=re.match('^[A-Za-z0-9._%+-]+@sanofi.com$', email)
                if emailcheck==None:
                    print("email address does not meet requirements")
                    return 'Error: invalid email address.'
                else: 
                    print("adminkeystub: {} ".format(adminkeystub))
                    adminsecret = getRoleSecretData(SManager, adminkeystub)
                    for value in adminsecret:
                        if value == 'adminkey' and adminsecret[value] == adminkey :
                            print("adminkey was valid... attempting to add role...")
                            #generate a token
                            token = generateRandomToken()
                            # turn the full arn of the role into a secret-compatible role name
                            roleStub = roleArnToRoleStub(rolename)
                            #check if the secret exists
                            secret = getRoleSecretData(SManager, roleStub)
                            if secret != None:
                                #if it exists, Rotate the key and update any date/time info for the secret
                                print("Secret already exists, attempting to update...")
                                response = updateRoleSecretData(SManager, roleStub, rolename, token, email)
                                if feature_outputlogging == 1:
                                    print("response: {}".format(response))
                                return "Success, token has been emailed to you"
                            else:
                                #if it does not yet exist, create the secret
                                print("Secret did not exist, attempting to create...")
                                response = createRoleSecretData(SManager, roleStub, rolename, token, email)
                                if feature_outputlogging == 1:
                                    print("response: {}".format(response))
                                return "Success, token has been emailed to you"
            except ClientError as e:
                print("Error in addrole: {} ".format(e))
                return None
    else:
        print("Lambda function is disabled.")

def sendEmail(SManager, email, roleARN, token):
    try:
        print(f"Preparing to send email to {email}")
        kwargs = {'SecretId': 'eccs/devops/roleretriever/smtp_password'}
        response = SManager.get_secret_value(**kwargs)
        #print("getRoleSecretData response : {} ".format(response))
        #smtpPass = response['SecretString']
        #print(f"Attempting to parse smtp values: {smtpPass}")
        if 'SecretString' in response:
            #if len(smtpPass) > 5:
            smtpPass = response['SecretString']
            print(f"Got SMTP Pass....")
            msg = EmailMessage()
            print(f"Created Email object")
            msg['Subject'] = f'DevOps Token Vending Service for IAM Role: {roleARN}'
            msg['From'] = "do-not-reply@sanofi.com"
            msg['To'] = email
            msg.set_content(f"The Security Token for {roleARN} has been set to {token}")
            print(f"Set Email values")
            # old smtp server = emea-aws-smtp-auth.service.cloud.local
            s = smtplib.SMTP('SMTP-AUTH-EU.sanofi.com',port=25, timeout=10)
            print(f"Attempting to log into email...")
            s.login("FRAsvcGitlabSMTP", smtpPass)
            print("Attempting to send email")
            s.send_message(msg)
            print("Email sent without error.")
            s.quit()
    except ClientError as e:
        print("Error in sendEmail: {} ".format(e))
        return None


def convertRoleToWildcardStub(roleArn):
    try:
        roleStub = ''
        #split role arn components into secretid format
        roleParts = roleArn.split(":")
        #roleParts[5] = roleParts[5].replace("role/", "")
        roleStub = "{}:{}:{}:{}:{}:{}".format(roleParts[0], roleParts[1], roleParts[2], roleParts[3], '@', roleParts[5])
        print('generated wildcard role stub: {} from roleParts: {}'.format(roleStub, roleParts))
        return roleStub
    except ClientError as e:
        print("Error in convertRoleToWildcardStub: {} ".format(e))
        return None

def roleArnToRoleStub(roleArn, wildcardrole=""):
    try:
        roleStub = ''
        #split role arn components into secretid format
        roleParts = roleArn.split(":")
        # not allowed to have the role/ prefix
        roleParts[5] = roleParts[5].replace("role/", "")
        if wildcardrole == 'true' :
            roleStub = "{}-{}".format('@', roleParts[5])
        else :
            roleStub = "{}-{}".format(roleParts[4], roleParts[5])
        print('generated role stub: {} from roleParts: {}'.format(roleStub, roleParts))
        return roleStub
    except ClientError as e:
        print("Error in roleArnToSecretId: {} ".format(e))
        return None

def generateRandomToken():
    validDigits = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    token = ""
    while len(token) < 64:
        token += random.choice(validDigits)
    #print('generated random token: {}'.format(token))
    return token

def createRoleSecretData(SManager, roleStub, roleARN, token, email):
    try:
        kwargs = {'Name': 'eccs/devops/roleretriever/{}'.format(roleStub)}
        kwargs["SecretString"] = '{ "' + roleARN + '": "' + token + '" }'
        print("Attempting createRoleSecretData with: {} ".format(json.dumps(kwargs)))
        response = SManager.create_secret(**kwargs)
        response2 = SManager.tag_resource(SecretId='eccs/devops/roleretriever/{}'.format(roleStub), Tags=[ {'Key': 'RequestorEmail', 'Value': email } ])
        sendEmail(SManager, email, roleARN, token)
        return response
    except ClientError as e:
        print("Error in createRoleSecretData: {} ".format(e))
        return None

def updateRoleSecretData(SManager, roleStub, roleARN, token, email):
    try:
        kwargs = {'SecretId': 'eccs/devops/roleretriever/{}'.format(roleStub)}
        kwargs["SecretString"] = '{ "' + roleARN + '": "' + token + '" }'
        print("Attempting updateRoleSecretData with: {} ".format(json.dumps(kwargs)))
        response = SManager.update_secret(**kwargs)
        response2 = SManager.tag_resource(SecretId='eccs/devops/roleretriever/{}'.format(roleStub), Tags=[ {'Key': 'RequestorEmail', 'Value': email } ])
        #email the token
        sendEmail(SManager, email, roleARN, token)
        return response
    except ClientError as e:
        print("Error in updateRoleSecretData: {} ".format(e))
        return None

def getRoleSecretData(SManager, roleStub):
    try:
        kwargs = {'SecretId': 'eccs/devops/roleretriever/{}'.format(roleStub)}
        print('attempting to getRoleSecretData on secret: {}'.format(kwargs))
        response = SManager.get_secret_value(**kwargs)
        #print("getRoleSecretData response : {} ".format(response))
        if 'SecretString' in response:
            secret = json.loads(response['SecretString'])
            return secret
    except ClientError as e:
        print("Error in getRoleSecretData: {} ".format(e))
        return None

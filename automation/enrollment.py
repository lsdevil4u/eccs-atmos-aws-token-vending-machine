try: 
    import os
    import re
    import boto3
    import typing
    import json
    import base64
    from github import Github
    from pprint import pprint
    print("All imports ok ...")
except Exception as e:
    print("Error Imports : {} ".format(e))
    
try:

    #proxy = 'emea-aws-webproxy.service.cloud.local:3128'

    #os.environ['http_proxy'] = proxy 
    os.environ['AWS_DEFAULT_REGION'] = 'eu-west-1'

    AdminKey = os.environ['TF_VAR_ADMINKEY']
    Title = os.environ['ENROLLMENT_TITLE']
    Message = os.environ['ENROLLMENT_MESSAGE']
    RepoURL = os.environ['REPO_URL']
    RepoName = os.environ['REPO_NAME'] 
    IssueNumber = os.environ['ENROLLMENT_NUMBER']
    token = os.environ['GITHUB_TOKEN']

    print("Processing request...")
    print("Issue Title : {} ".format(Title))
    print("Issue Message : {} ".format(Message))
    #if Title.lower()!="AWS Role Enrollment".lower():
    #    print("Issue Title '{}' doesn't match : {} ".format(Title, "AWS Role Enrollment"))
                

    email = None
    arn = None
    wildcard = False

    lines = Message.splitlines()
    
    emailLine = lines[2]
    emailcheck=re.match('^[A-Za-z0-9._%+-]+@sanofi.com$', emailLine)
    if emailcheck==None:
        print("email address {} does not meet requirements".format(emailLine))
        exit
    else: 
        print("email address check completed successfully for {}".format(emailLine))
        email = emailLine

    try:
        wildcardLine = lines[10]
        print(f"wildcard line: {wildcardLine}")
        wcCheck=re.match('- \[X\] This is a Wildcard Role', wildcardLine)
        if wcCheck==None:
            # this is not a wildcard role
            wildcard = False
            print(f"Wildcard disabled")
        else:
            wildcard = True
            print(f"Wildcard enabled")
    except Exception as e:
            print("Error looking for wildcard role information, (perhaps it was not enabled...) : {} ".format(e))

    arnLine = lines[6]
    print(f"role line: {arnLine}")
    if wildcard:
        arnCheck=re.match('^arn:aws:iam::@:role/.+', arnLine)
    else:
        arnCheck=re.match('^arn:aws:iam::\d{12}:role/.+', arnLine)

    if arnCheck==None:
        print("iam role format {} does not meet requirements".format(arnLine))
        exit
    else:
        arn = arnLine

    # for line in lines:
    #     if "Your Email:".lower() in line.lower():
    #         line = line.replace("Your Email:", "")
    #         line = line.strip()
    #         emailcheck=re.match('^[A-Za-z0-9._%+-]+@sanofi.com$', line)
    #         if emailcheck==None:
    #             print("email address does not meet requirements")
    #             exit
    #         else: 
    #             email = line
    #     if "AWS Role ARN:".lower() in line.lower():
    #         line = line.replace("AWS Role ARN:", "")
    #         line = line.strip()
    #         arnCheck=re.match('^arn:aws:iam::\d{12}:role/.+', line)
    #         if arnCheck==None:
    #             print("iam role format does not meet requirements")
    #             exit
    #         else: 
    #             arn = line

    if arn!=None and email!=None:
        print("enrollment requirements met")

        try:

            client = boto3.client('lambda')

            # aws lambda invoke --function-name App_RoleRetriever --payload '{"action": "addrole", "role": "arn:aws:iam::@:role/App_roleretriever_lambda_assume", "email":"nicholas.furno@sanofi.com", "adminkey":"${{ secrets.TF_VAR_ADMINKEY}}"}' --region eu-west-1 token.json
            payload = {
                'action': 'addrole', 
                'role': arn, 
                'email': email, 
                'adminkey': AdminKey,
                'wildcard': wildcard
            }
            response = client.invoke(
                    FunctionName='App_RoleRetriever',
                    LogType='None',
                    Payload=json.dumps(payload)
            )
            print("enrollment response: {}".format(response))

        except Exception as e:
            print("Lambda Invokation Error : {} ".format(e))


        try: 
            
            #maybe add something that checks for response code 200

            g = Github(token)
            print("Github Issue Update : connected")
            repo = g.get_repo(RepoName)
            print("Github Issue Update repo : {} ".format(repo))
            issue = repo.get_issue(number=int(IssueNumber))
            print("Github Issue Update issue : {} ".format(issue))
            comment = issue.create_comment("Enrollment completed successfully. An email will be sent shortly containing your secret token.")
            print("Github Issue Update comment : {} ".format(comment))
            status = issue.edit(state='closed')
            print("Github Issue Update status : {} ".format(status))

        except Exception as e:
            print("Github Issue Update error : {} ".format(e))
        
        exit

        

except Exception as e:
    print("Script Error : {} ".format(e))



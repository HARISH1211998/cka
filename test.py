"""
Redis 6 AWS Celery Integration with TLS and KMS

This module configures Celery with:
- Redis 6 as broker/backend
- TLS encryption
- Token authentication
- AWS KMS for certificate management
"""

import os
import ssl
import boto3
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from celery import Celery
from celery.signals import worker_init

KMS_KEY_ID = 'c794e26a-428d-4bec-a07f-aeeff4c95f1d'
REDIS_HOST = 'master.denex-test-devnet.jzfjn6.apse1.cache.amazonaws.com'
REDIS_PORT = 6379
REDIS_TOKEN = 'lhNjVDeOUwAtPBMb'
REDIS_DB = 0
CELERY_APP_NAME = 'redis6_kms_celery_app'
CELERY_TASK_MODULES = ['tasks']
AWS_REGION = 'ap-southeast-1'
kms_client = boto3.client('kms', region_name=AWS_REGION)

class KMSCertificateManager:
    """Handles TLS certificates stored in AWS KMS"""
    
    def __init__(self, kms_key_id):
        self.kms_key_id = kms_key_id
        self.cert_cache = {}
    
    def get_public_key(self):
        """Retrieve public key from KMS"""
        try:
            response = kms_client.get_public_key(KeyId=self.kms_key_id)
            public_key = serialization.load_der_public_key(
                response['PublicKey'],
                backend=default_backend()
            )
            return public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo
            )
        except Exception as e:
            raise Exception(f"Failed to retrieve public key from KMS: {str(e)}")

    def decrypt_token(self, encrypted_token):
        """Decrypt Redis token using KMS"""
        try:
            response = kms_client.decrypt(
                KeyId=self.kms_key_id,
                CiphertextBlob=encrypted_token
            )
            return response['Plaintext'].decode('utf-8')
        except Exception as e:
            raise Exception(f"Failed to decrypt token with KMS: {str(e)}")

def configure_redis_ssl(cert_manager):
    """Configure SSL context using KMS-managed certificates"""
    try:
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = True
        ssl_context.verify_mode = ssl.CERT_REQUIRED
        return {
            'ssl_cert_reqs': ssl.CERT_REQUIRED,
            'ssl_context': ssl_context
        }
    except Exception as e:
        raise Exception(f"Failed to configure Redis SSL: {str(e)}")

def make_celery_app():
    """Create and configure Celery application"""
    cert_manager = KMSCertificateManager(KMS_KEY_ID)
    redis_token = REDIS_TOKEN
    
    redis_url = (
        f"rediss://default:{redis_token}@{REDIS_HOST}:{REDIS_PORT}/{REDIS_DB}"
        "?ssl_cert_reqs=required"
    )   
    app = Celery(
        CELERY_APP_NAME,
        broker=redis_url,
        backend=redis_url,
        include=CELERY_TASK_MODULES
    )
    app.conf.update(
        task_serializer='json',
        accept_content=['json'],
        result_serializer='json',
        timezone='UTC',
        enable_utc=True,
        task_track_started=True,
        worker_send_task_events=True,
        task_send_sent_event=True,
        broker_connection_retry_on_startup=True,
        broker_transport_options=configure_redis_ssl(cert_manager),
        redis_backend_use_ssl=configure_redis_ssl(cert_manager)
    )
    
    return app

celery_app = make_celery_app()

@worker_init.connect
def setup_kms_ssl_on_worker_init(sender=None, conf=None, **kwargs):
    """Configure SSL when worker starts"""
    cert_manager = KMSCertificateManager(KMS_KEY_ID)
    conf.broker_use_ssl = configure_redis_ssl(cert_manager)
    conf.redis_backend_use_ssl = configure_redis_ssl(cert_manager)

if __name__ == '__main__':
    celery_app.start(argv=[
        'worker',
        '--loglevel=info',
        '--without-heartbeat',
        '--without-mingle',
        '--without-gossip',
        '--pool=solo', 
        '--concurrency=4'
    ])
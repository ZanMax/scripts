package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/feature/s3/manager"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {
	// Parse command-line parameter for the filename
	filePath := flag.String("file", "", "Path to the file you want to upload")
	flag.Parse()

	if *filePath == "" {
		log.Fatal("Please provide a file path using the -file parameter.")
	}

	awsAccessKeyID := "your_access_key_id"
	awsSecretAccessKey := "your_secret_access_key"
	credProvider := credentials.NewStaticCredentialsProvider(awsAccessKeyID, awsSecretAccessKey, "")

	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-west-2"), config.WithCredentialsProvider(credProvider))
	if err != nil {
		log.Fatalf("unable to load SDK config: %v", err)
	}

	s3Client := s3.NewFromConfig(cfg)

	// Replace with your desired S3 bucket name
	bucket := "your-bucket-name"

	// Generate a unique bucket file name using the input filename and current timestamp
	bucketFileName := generateUniqueBucketFileName(*filePath)

	err = UploadFileToS3(context.TODO(), s3Client, *filePath, bucket, bucketFileName)
	if err != nil {
		log.Fatalf("failed to upload file to S3: %v", err)
	} else {
		fmt.Println("File uploaded successfully!")
	}
}

func generateUniqueBucketFileName(filePath string) string {
	inputFileName := filepath.Base(filePath)
	currentTimestamp := time.Now().Format("20060102150405")
	return fmt.Sprintf("%s-%s", currentTimestamp, inputFileName)
}

func UploadFileToS3(ctx context.Context, client *s3.Client, filePath, bucket, bucketFileName string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open file %q, %v", filePath, err)
	}
	defer file.Close()

	uploader := manager.NewUploader(client)
	_, err = uploader.Upload(ctx, &s3.PutObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(bucketFileName),
		Body:   file,
	})
	if err != nil {
		return fmt.Errorf("failed to upload object, %v", err)
	}

	return nil
}

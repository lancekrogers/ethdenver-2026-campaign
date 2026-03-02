package main

import (
	"fmt"
	"log/slog"
	"math/big"

	"cre-hello-world/contracts/evm/src/generated/trivial"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"

	"github.com/smartcontractkit/cre-sdk-go/capabilities/blockchain/evm"
	"github.com/smartcontractkit/cre-sdk-go/capabilities/scheduler/cron"
	"github.com/smartcontractkit/cre-sdk-go/cre"
)

type ExecutionResult struct {
	Result string
}

type Config struct {
	ContractAddress string `json:"contractAddress"`
	ChainName       string `json:"chainName"`
}

func InitWorkflow(config *Config, logger *slog.Logger, secretsProvider cre.SecretsProvider) (cre.Workflow[*Config], error) {
	cronTrigger := cron.Trigger(&cron.Config{Schedule: "*/30 * * * * *"})

	return cre.Workflow[*Config]{
		cre.Handler(cronTrigger, onCronTrigger),
	}, nil
}

func onCronTrigger(config *Config, runtime cre.Runtime, trigger *cron.Payload) (*ExecutionResult, error) {
	logger := runtime.Logger()
	scheduledTime := trigger.ScheduledExecutionTime.AsTime()
	logger.Info("Cron trigger fired", "scheduledTime", scheduledTime)

	// Create EVM client
	chainSelector, err := evm.ChainSelectorFromName(config.ChainName)
	if err != nil {
		return nil, fmt.Errorf("failed to get chain selector: %w", err)
	}
	evmClient := &evm.Client{ChainSelector: chainSelector}

	// Create trivial contract binding
	address := common.HexToAddress(config.ContractAddress)
	contract, err := trivial.NewTrivial(evmClient, address, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create trivial binding: %w", err)
	}

	// Generate a report with a uint256 value and write it on-chain
	newValue := big.NewInt(42)
	uint256Type, _ := abi.NewType("uint256", "", nil)
	args := abi.Arguments{{Type: uint256Type}}
	encodedValue, err := args.Pack(newValue)
	if err != nil {
		return nil, fmt.Errorf("failed to encode value: %w", err)
	}

	report, err := runtime.GenerateReport(&cre.ReportRequest{
		EncodedPayload: encodedValue,
		EncoderName:    "evm",
	}).Await()
	if err != nil {
		return nil, fmt.Errorf("failed to generate report: %w", err)
	}

	resp, err := contract.WriteReport(runtime, report, nil).Await()
	if err != nil {
		return nil, fmt.Errorf("failed to write report: %w", err)
	}
	logger.Info("Write report succeeded", "txHash", common.BytesToHash(resp.TxHash).Hex())

	return &ExecutionResult{Result: fmt.Sprintf("Fired at %s, wrote value %d", scheduledTime, newValue)}, nil
}

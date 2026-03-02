// Code generated — DO NOT EDIT.

package trivial

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"math/big"
	"reflect"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
	"github.com/ethereum/go-ethereum/rpc"
	"google.golang.org/protobuf/types/known/emptypb"

	pb2 "github.com/smartcontractkit/chainlink-protos/cre/go/sdk"
	"github.com/smartcontractkit/chainlink-protos/cre/go/values/pb"
	"github.com/smartcontractkit/cre-sdk-go/capabilities/blockchain/evm"
	"github.com/smartcontractkit/cre-sdk-go/capabilities/blockchain/evm/bindings"
	"github.com/smartcontractkit/cre-sdk-go/cre"
)

var (
	_ = bytes.Equal
	_ = errors.New
	_ = fmt.Sprintf
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
	_ = emptypb.Empty{}
	_ = pb.NewBigIntFromInt
	_ = pb2.AggregationType_AGGREGATION_TYPE_COMMON_PREFIX
	_ = bindings.FilterOptions{}
	_ = evm.FilterLogTriggerRequest{}
	_ = cre.ResponseBufferTooSmall
	_ = rpc.API{}
	_ = json.Unmarshal
	_ = reflect.Bool
)

var TrivialMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"function\",\"name\":\"setValue\",\"inputs\":[{\"name\":\"_value\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"value\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"ValueSet\",\"inputs\":[{\"name\":\"newValue\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"setter\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"}],\"anonymous\":false}]",
}

// Structs

// Contract Method Inputs
type SetValueInput struct {
	Value *big.Int
}

// Contract Method Outputs

// Errors

// Events
// The <Event>Topics struct should be used as a filter (for log triggers).
// Note: It is only possible to filter on indexed fields.
// Indexed (string and bytes) fields will be of type common.Hash.
// They need to he (crypto.Keccak256) hashed and passed in.
// Indexed (tuple/slice/array) fields can be passed in as is, the Encode<Event>Topics function will handle the hashing.
//
// The <Event>Decoded struct will be the result of calling decode (Adapt) on the log trigger result.
// Indexed dynamic type fields will be of type common.Hash.

type ValueSetTopics struct {
}

type ValueSetDecoded struct {
	NewValue *big.Int
	Setter   common.Address
}

// Main Binding Type for Trivial
type Trivial struct {
	Address common.Address
	Options *bindings.ContractInitOptions
	ABI     *abi.ABI
	client  *evm.Client
	Codec   TrivialCodec
}

type TrivialCodec interface {
	EncodeSetValueMethodCall(in SetValueInput) ([]byte, error)
	EncodeValueMethodCall() ([]byte, error)
	DecodeValueMethodOutput(data []byte) (*big.Int, error)
	ValueSetLogHash() []byte
	EncodeValueSetTopics(evt abi.Event, values []ValueSetTopics) ([]*evm.TopicValues, error)
	DecodeValueSet(log *evm.Log) (*ValueSetDecoded, error)
}

func NewTrivial(
	client *evm.Client,
	address common.Address,
	options *bindings.ContractInitOptions,
) (*Trivial, error) {
	parsed, err := abi.JSON(strings.NewReader(TrivialMetaData.ABI))
	if err != nil {
		return nil, err
	}
	codec, err := NewCodec()
	if err != nil {
		return nil, err
	}
	return &Trivial{
		Address: address,
		Options: options,
		ABI:     &parsed,
		client:  client,
		Codec:   codec,
	}, nil
}

type Codec struct {
	abi *abi.ABI
}

func NewCodec() (TrivialCodec, error) {
	parsed, err := abi.JSON(strings.NewReader(TrivialMetaData.ABI))
	if err != nil {
		return nil, err
	}
	return &Codec{abi: &parsed}, nil
}

func (c *Codec) EncodeSetValueMethodCall(in SetValueInput) ([]byte, error) {
	return c.abi.Pack("setValue", in.Value)
}

func (c *Codec) EncodeValueMethodCall() ([]byte, error) {
	return c.abi.Pack("value")
}

func (c *Codec) DecodeValueMethodOutput(data []byte) (*big.Int, error) {
	vals, err := c.abi.Methods["value"].Outputs.Unpack(data)
	if err != nil {
		return *new(*big.Int), err
	}
	jsonData, err := json.Marshal(vals[0])
	if err != nil {
		return *new(*big.Int), fmt.Errorf("failed to marshal ABI result: %w", err)
	}

	var result *big.Int
	if err := json.Unmarshal(jsonData, &result); err != nil {
		return *new(*big.Int), fmt.Errorf("failed to unmarshal to *big.Int: %w", err)
	}

	return result, nil
}

func (c *Codec) ValueSetLogHash() []byte {
	return c.abi.Events["ValueSet"].ID.Bytes()
}

func (c *Codec) EncodeValueSetTopics(
	evt abi.Event,
	values []ValueSetTopics,
) ([]*evm.TopicValues, error) {

	rawTopics, err := abi.MakeTopics()
	if err != nil {
		return nil, err
	}

	return bindings.PrepareTopics(rawTopics, evt.ID.Bytes()), nil
}

// DecodeValueSet decodes a log into a ValueSet struct.
func (c *Codec) DecodeValueSet(log *evm.Log) (*ValueSetDecoded, error) {
	event := new(ValueSetDecoded)
	if err := c.abi.UnpackIntoInterface(event, "ValueSet", log.Data); err != nil {
		return nil, err
	}
	var indexed abi.Arguments
	for _, arg := range c.abi.Events["ValueSet"].Inputs {
		if arg.Indexed {
			if arg.Type.T == abi.TupleTy {
				// abigen throws on tuple, so converting to bytes to
				// receive back the common.Hash as is instead of error
				arg.Type.T = abi.BytesTy
			}
			indexed = append(indexed, arg)
		}
	}
	// Convert [][]byte → []common.Hash
	topics := make([]common.Hash, len(log.Topics))
	for i, t := range log.Topics {
		topics[i] = common.BytesToHash(t)
	}

	if err := abi.ParseTopics(event, indexed, topics[1:]); err != nil {
		return nil, err
	}
	return event, nil
}

func (c Trivial) Value(
	runtime cre.Runtime,
	blockNumber *big.Int,
) cre.Promise[*big.Int] {
	calldata, err := c.Codec.EncodeValueMethodCall()
	if err != nil {
		return cre.PromiseFromResult[*big.Int](*new(*big.Int), err)
	}

	var bn cre.Promise[*pb.BigInt]
	if blockNumber == nil {
		promise := c.client.HeaderByNumber(runtime, &evm.HeaderByNumberRequest{
			BlockNumber: bindings.FinalizedBlockNumber,
		})

		bn = cre.Then(promise, func(finalizedBlock *evm.HeaderByNumberReply) (*pb.BigInt, error) {
			if finalizedBlock == nil || finalizedBlock.Header == nil {
				return nil, errors.New("failed to get finalized block header")
			}
			return finalizedBlock.Header.BlockNumber, nil
		})
	} else {
		bn = cre.PromiseFromResult(pb.NewBigIntFromInt(blockNumber), nil)
	}

	promise := cre.ThenPromise(bn, func(bn *pb.BigInt) cre.Promise[*evm.CallContractReply] {
		return c.client.CallContract(runtime, &evm.CallContractRequest{
			Call:        &evm.CallMsg{To: c.Address.Bytes(), Data: calldata},
			BlockNumber: bn,
		})
	})
	return cre.Then(promise, func(response *evm.CallContractReply) (*big.Int, error) {
		return c.Codec.DecodeValueMethodOutput(response.Data)
	})

}

func (c Trivial) WriteReport(
	runtime cre.Runtime,
	report *cre.Report,
	gasConfig *evm.GasConfig,
) cre.Promise[*evm.WriteReportReply] {
	return c.client.WriteReport(runtime, &evm.WriteCreReportRequest{
		Receiver:  c.Address.Bytes(),
		Report:    report,
		GasConfig: gasConfig,
	})
}

func (c *Trivial) UnpackError(data []byte) (any, error) {
	switch common.Bytes2Hex(data[:4]) {
	default:
		return nil, errors.New("unknown error selector")
	}
}

// ValueSetTrigger wraps the raw log trigger and provides decoded ValueSetDecoded data
type ValueSetTrigger struct {
	cre.Trigger[*evm.Log, *evm.Log]          // Embed the raw trigger
	contract                        *Trivial // Keep reference for decoding
}

// Adapt method that decodes the log into ValueSet data
func (t *ValueSetTrigger) Adapt(l *evm.Log) (*bindings.DecodedLog[ValueSetDecoded], error) {
	// Decode the log using the contract's codec
	decoded, err := t.contract.Codec.DecodeValueSet(l)
	if err != nil {
		return nil, fmt.Errorf("failed to decode ValueSet log: %w", err)
	}

	return &bindings.DecodedLog[ValueSetDecoded]{
		Log:  l,        // Original log
		Data: *decoded, // Decoded data
	}, nil
}

func (c *Trivial) LogTriggerValueSetLog(chainSelector uint64, confidence evm.ConfidenceLevel, filters []ValueSetTopics) (cre.Trigger[*evm.Log, *bindings.DecodedLog[ValueSetDecoded]], error) {
	event := c.ABI.Events["ValueSet"]
	topics, err := c.Codec.EncodeValueSetTopics(event, filters)
	if err != nil {
		return nil, fmt.Errorf("failed to encode topics for ValueSet: %w", err)
	}

	rawTrigger := evm.LogTrigger(chainSelector, &evm.FilterLogTriggerRequest{
		Addresses:  [][]byte{c.Address.Bytes()},
		Topics:     topics,
		Confidence: confidence,
	})

	return &ValueSetTrigger{
		Trigger:  rawTrigger,
		contract: c,
	}, nil
}

func (c *Trivial) FilterLogsValueSet(runtime cre.Runtime, options *bindings.FilterOptions) (cre.Promise[*evm.FilterLogsReply], error) {
	if options == nil {
		return nil, errors.New("FilterLogs options are required.")
	}
	return c.client.FilterLogs(runtime, &evm.FilterLogsRequest{
		FilterQuery: &evm.FilterQuery{
			Addresses: [][]byte{c.Address.Bytes()},
			Topics: []*evm.Topics{
				{Topic: [][]byte{c.Codec.ValueSetLogHash()}},
			},
			BlockHash: options.BlockHash,
			FromBlock: pb.NewBigIntFromInt(options.FromBlock),
			ToBlock:   pb.NewBigIntFromInt(options.ToBlock),
		},
	}), nil
}

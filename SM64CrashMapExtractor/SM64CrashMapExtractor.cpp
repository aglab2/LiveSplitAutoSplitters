#include <iostream>
#include <fstream>
#include <sstream>

#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>

// couple classic defines
#define bswap32(x) _byteswap_ulong(x)
#define ROUND_UP(N, S) ((((N) + (S) - 1) / (S)) * (S))
#define ROUND_DOWN(N,S) (((N) / (S)) * (S))
#define MB (1024 * 1024)

static const char* makePath(int argc, const char* argv[])
{
	if (argc < 2)
		return nullptr;

	return argv[1];
}

static std::string readFileContents(const char* path)
{
	std::ifstream file{ path, std::ios::binary };
	std::stringstream buffer;
	buffer << file.rdbuf();
	return buffer.str();
}

template<typename T>
static T loadByteSwapped(const std::string& data, size_t offset)
{
	T val;
	size_t pos = offset;

	uint32_t* ival = (uint32_t*)&val;
	const uint32_t* idat = (const uint32_t*) &data[offset];

	for (int i = 0; i < sizeof(T) / 4; i++)
	{
		ival[i] = bswap32(idat[i]);
	}

	return val;
}

struct MapEntry {
	uint32_t addr;
	uint32_t nm_offset;
	uint32_t nm_len;
	uint32_t pad;
};

static bool verify(const MapEntry& entry)
{
	if (entry.pad != 0)
		return false;

	// must be 0x80 vaddr at the beginning hence negative integer
	if (((int32_t)entry.addr) >= 0)
		return false;

	// 1MB is unreasonable for the offset or length
	if (entry.nm_offset > 0x1000000)
		return false;

	if (entry.nm_len > 0x1000000)
		return false;

	return true;
}

static bool verify(const std::string& data, size_t offset, size_t size)
{
	return offset + size < data.size();
}

#define DIE(fmt, ...)  do{ fprintf(stderr, fmt "\n", ##__VA_ARGS__); exit(1); }while(0)
#define WARN(fmt, ...) do{ fprintf(stderr, fmt "\n", ##__VA_ARGS__);		  }while(0)

int main(int argc, const char* argv[])
{
	const char* path = makePath(argc, argv);
	if (!path)
	{
		DIE("Path is not detected");
	}

	std::string contents = readFileContents(path);
	if (contents.size() < 1 * MB)
	{
		DIE("Contents are too small");
	}

	// seek for the data that looks like map parts
	// it should be in the end of the file with a specific format
	MapEntry entry;
	size_t offset = ROUND_DOWN(contents.size(), 16);

	// scan till first valid entry
	do
	{
		if (contents.size() > offset + 1 * MB)
			DIE("Failed to find map entries in 1MB");

		offset -= sizeof(MapEntry);
		entry = loadByteSwapped<MapEntry>(contents, offset);
	} while (!verify(entry));
	size_t mapEntriesEnd = offset + sizeof(MapEntry);

	// continue scanning further till entries become invalid again
	do
	{
		offset -= sizeof(MapEntry);
		entry = loadByteSwapped<MapEntry>(contents, offset);
	} while (verify(entry));
	size_t mapEntriesStart = offset + sizeof(MapEntry);

	size_t namesStart = mapEntriesEnd;

	// print the crap out
	for (offset = mapEntriesStart; offset < mapEntriesEnd; offset += sizeof(MapEntry))
	{
		// TODO: Useless load, done already during verifications
		entry = loadByteSwapped<MapEntry>(contents, offset);
		if (!verify(contents, entry.nm_len, entry.nm_offset))
		{
			WARN("Failed to verify entry { 0x%08x, 0x%x, 0x%x }, skipping", entry.addr, entry.nm_offset, entry.nm_len);
			continue;
		}

		std::string str{ &contents[namesStart + entry.nm_offset], entry.nm_len };
		printf("0x%08x %s\n", entry.addr, str.c_str());
	}

	return 0;
}

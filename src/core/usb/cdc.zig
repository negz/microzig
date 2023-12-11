// USB CDC
//
// This is just enough implementation to allow us to act as a USB serial device.
// https://cscott.net/usb_dev/data/devclass/usbcdc11.pdf

const std = @import("std");

pub const DescType = enum(u8) {
    /// Class-specific descriptor
    ClassSpecific = 0x24,

    pub fn from_u16(v: u16) ?@This() {
        return switch (v) {
            0x24 => @This().ClassSpecific,
            else => null,
        };
    }
};

pub const DescSubType = enum(u8) {
    Header = 0x00,
    CallManagement = 0x01,
    ACM = 0x02,
    Union = 0x06,

    pub fn from_u16(v: u16) ?@This() {
        return switch (v) {
            0x00 => @This().Header,
            0x01 => @This().CallManagement,
            0x02 => @This().ACM,
            0x06 => @This().Union,
        };
    }
};

pub const ClassSpecificCDCHeader = extern struct {
    // Length of this structure, must be 5.
    length: u8,
    // Type of this descriptor, must be `ClassSpecific`.
    descriptor_type: DescType,
    // Subtype of this descriptor, must be `Header`.
    descriptor_subtype: DescSubType,
    // USB Class Definitions for Communication Devices Specification release
    // number in binary-coded decimal. Typically 0x01_10.
    bcd_cdc: u16,

    pub fn serialize(self: *const @This()) [8]u8 {
        var out: [8]u8 = undefined;
        out[0] = 5; // length
        out[1] = @intFromEnum(self.descriptor_type);
        out[2] = @intFromEnum(self.descriptor_subtype);
        out[3] = @intCast(self.bcd_cdc & 0xff);
        out[4] = @intCast((self.bcd_cdc >> 8) & 0xff);
        return out;
    }
};

pub const ClassSpecificCDCCallManagement = extern struct {
    // Length of this structure, must be 5.
    length: u8,
    // Type of this descriptor, must be `ClassSpecific`.
    descriptor_type: DescType,
    // Subtype of this descriptor, must be `CallManagement`.
    descriptor_subtype: DescSubType,
    // Capabilities. Should be 0x00 for use as a serial device.
    capabilities: u8,
    // Data interface number.
    data_interface: u8,

    pub fn serialize(self: *const @This()) [8]u8 {
        var out: [8]u8 = undefined;
        out[0] = 5; // length
        out[1] = @intFromEnum(self.descriptor_type);
        out[2] = @intFromEnum(self.descriptor_subtype);
        out[3] = self.capabilities;
        out[4] = self.data_interface;
        return out;
    }
};

pub const ClassSpecificCDCACM = extern struct {
    // Length of this structure, must be 4.
    length: u8,
    // Type of this descriptor, must be `ClassSpecific`.
    descriptor_type: DescType,
    // Subtype of this descriptor, must be `ACM`.
    descriptor_subtype: DescSubType,
    // Capabilities. Should be 0x02 for use as a serial device.
    capabilities: u8,

    pub fn serialize(self: *const @This()) [8]u8 {
        var out: [8]u8 = undefined;
        out[0] = 4; // length
        out[1] = @intFromEnum(self.descriptor_type);
        out[2] = @intFromEnum(self.descriptor_subtype);
        out[3] = self.capabilities;
        return out;
    }
};

pub const ClassSpecificCDCUnion = extern struct {
    // Length of this structure, must be 5.
    length: u8,
    // Type of this descriptor, must be `ClassSpecific`.
    descriptor_type: DescType,
    // Subtype of this descriptor, must be `Union`.
    descriptor_subtype: DescSubType,
    // The interface number of the communication or data class interface
    // designated as the master or controlling interface for the union.
    master_interface: u8,
    // The interface number of the first slave or associated interface in the
    // union.
    slave_interface_0: u8,

    pub fn serialize(self: *const @This()) [8]u8 {
        var out: [8]u8 = undefined;
        out[0] = 5; // length
        out[1] = @intFromEnum(self.descriptor_type);
        out[2] = @intFromEnum(self.descriptor_subtype);
        out[3] = self.master_interface;
        out[4] = self.slave_interface_0;
        return out;
    }
};

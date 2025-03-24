<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 견적서관리 > 장비견적서등록 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        <%-- 여기에 스크립트 넣어주세요. --%>
        var isCust = false;
        var isMachine = false;
        var optList = [];
        var auiGridOption; // 선택사항
        var auiGridAttach; // 어테치먼트
        var auiGridPart; // 유상부품
        var auiGridPartFree; // 무상부품
        var auiGridBasic; // 기본제공품(hidden)
        var parentPaidList; // 유상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)
        var parentFreeList; // 무상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)
        var codeMapCostItemArray = JSON.parse('${codeMapJsonObj['COST_ITEM']}');
        var openPopupYN = '${inputParam.open_popup_yn}'; // 팝업으로 열렸으면 Y

        $(document).ready(function () {
            if ( parent.fnStyleChange )
                parent.fnStyleChange('Y', 'add');

            fnSetExpireDt();
            createAUIGrid();

            if (openPopupYN == 'Y') { // 팝업으로 열였는지?
                var menu_seq = '${inputParam.menu_seq}';
                if (menu_seq == '3200') { // 메뉴가 장비상세에서 넘어왔는지?
                    var row = {
                        machine_name: '${inputParam.machine_name}',
                        machine_plant_seq: '${inputParam.machine_plant_seq}',
                    }
                    fnSetModelInfo(row);
                }
            }

        });

        function fnSetExpireDt() {
            var rfqDt = $M.getValue("rfq_dt");
            $M.setValue("expire_dt", $M.addDates($M.toDate(rfqDt), 30));
        }

        /*
        * 어테치먼트가 = 옵션 선택시 + / 기본 선택 해제 -
        * 최종판매금액(sale_amt) = (기준판매가 + 어테치먼트가) - 가격할인금액
        * 총액(total_vat_amt) = 최종판매가 + VAT (10%)
        * 합계(total_amt) = 기준판매가 + 장비대에 영향을 미치는 합계(유상, 어테치먼트.. ) 화면에 안보이게 hidden 처리
        **/
        function fnChangePrice() {
            if ($M.getValue("machine_name") == "") {
                alert("모델을 먼저 검색해주세요.");
                $M.setValue("discount_amt", "0");
                $("#machine_name").focus();
                return false;
            }
            var price = $M.toNum($M.getValue("sale_price")); // 기준판매가
            var attach = $M.toNum($M.getValue("attach_amt")); // 어테치먼트
            var paid = $M.toNum($M.getValue("part_cost_amt")); // 유상
            var dc = $M.toNum($M.getValue("discount_amt"));
            if ((price + attach + paid) < dc && dc > 0) {
                alert("할인액은 최종판매가(" + $M.setComma(price + attach + paid) + ")를 초과할 수 없습니다.\n최종판매가를 올리려면 할인액을 마이너스로 입력하세요.");
                $M.setValue("discount_amt", (price + attach + paid));
                $M.setValue("discount_rate", "100");
                dc = (price + attach);
            }
            var saleAmt = price + attach - dc; // 최종판매가(기준판매가+어테치+dc)
            var t = price + attach + paid;
            var rate = 0;
            console.log(dc, t)
            if (dc > 0) {
                rate = dc / t * 100;
            } else {
                rate = 0;
            }
            var price = {
                discount_amt_temp: dc,
                discount_rate: rate,
                sale_amt: saleAmt,
                total_amt: saleAmt + paid,
                vat: Math.floor((saleAmt + paid) * 0.1), // 부가세 : 최종판매가 * 0.1
                rfq_amt: Math.floor((saleAmt + paid) * 1.1) // 총액(VAT포함) : 최종판매가 + VAT
            };
            $M.setValue(price);
        }

        // 초기화
        function fnInit() {
            var param = {
                sale_price: "0",
                part_free_amt: "0",
                discount_amt: "0",
                agency_price: "0",
                part_cost_amt: "0",
                part_free_amt: "0",
                attach_amt: "0",
                sale_amt: "0",
                write_price: "0",
                review_price: "0",
                agree_price: "0",
                max_dc_price: "0",
                fee_price: "0",
                discount_rate: "0",
                discount_amt: "0",
                discount_amt_temp: "0",
                total_amt: "0"
            }
            $M.clearValue();
            // 선택사항 그리드 초기화
            AUIGrid.setGridData(auiGridOption, []);
            // 어테치먼트 그리드 초기화
            AUIGrid.setGridData(auiGridAttach, []);
            // 기본제공품 그리드 초기화
            AUIGrid.setGridData(auiGridBasic, []);
            // 유상그리드 초기화
            AUIGrid.setGridData(auiGridPart, []);
            // 무상그리드 초기화
            AUIGrid.setGridData(auiGridPartFree, []);
            $M.setValue(param);
        }

        // 엔터키 이벤트
        function enter(fieldObj) {
            var name = fieldObj.name;
            if (name == "machine_name") {
                goModelInfo();
            } else if (name == "cust_name") {
                goCustInfo();
            }
        }

        function goModelInfoClick() {
            if (isMachine == true) {
                if (confirm("모델을 다시 조회하면 입력한 값이 초기화됩니다.\n다시 조회하시겠습니까?") == false) {
                    return false;
                }
            }
            var param = {
                s_price_present_yn: "Y"
            };
            openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
        }


        // 모델조회(단일)
        function goModelInfo() {
            if (isMachine == true) {
                if (confirm("모델을 다시 조회하면 입력한 값이 초기화됩니다.\n다시 조회하시겠습니까?") == false) {
                    return false;
                }
            }
            var param = {
                s_price_present_yn: "Y"
            };
            var url = "/comp/comp0501";
            $M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    console.log(result);
                    if (result.success) {
                        $("#machine_name").blur();
                        var list = result.list;
                        switch (list.length) {
                            case 0 :
                                $M.clearValue({field: ["machine_name", "machine_plant_seq"]});
                                break;
                            case 1 :
                                var row = list[0];
                                fnSetModelInfo(row)
                                break;
                            default :
                                openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
                                break;
                        }
                    }
                }
            );
        }

        function fnSetModelInfo(row) {
            fnInit();
            isMachine = true;
            $M.setValue("machine_name", row.machine_name);
            $M.setValue("machine_plant_seq", row.machine_plant_seq);
            $M.goNextPageAjax("/machine/supplement/" + row.machine_plant_seq, "", {method: 'GET'},
                function (result) {
                    if (result.success) {
                        // 가격
                        if (result.basicInfo) {
                            alert("모델을 변경했습니다.");
                            $M.setValue(result.basicInfo);
                        } else {
                            alert("이 장비의 기본정보를 조회할 수 없습니다.");
                            return false;
                        }

                        // 조회 시, 정상판매가(sale_price) = 최종판매금액(sale_amt) default
                        // 부가정보 조작 시, 최종판매금액을 수정함.
                        $M.setValue("sale_amt", result.basicInfo.sale_price);
                        fnChangePrice();

                        // 선택사항
                        optList = result.optionList;
                        $("#opt_code").html("");
                        if (optList.length > 0) {
                            $("#opt_code").css("display", "inline-block");
                            for (var i = 0; i < optList.length; ++i) {
                                $("#opt_code").append("<option value='" + optList[i].opt_code + "'>" + optList[i].opt_name + "</option>");
                            }
                            $M.setValue("opt_code", optList[0].opt_code);
                            AUIGrid.setGridData("#auiGridOption", optList[0].list);
                        } else {
                            $("#opt_code").css("display", "none");
                            AUIGrid.setGridData("#auiGridOption", []);
                        }
                        if (result.attachList) {
                            // 어테치먼트
                            /* for (var i = 0; i < result.attachList.length; ++i) {
                                if (result.attachList[i].attach_base_yn == "Y") {
                                    result.attachList[i]['gubun'] = "기본";
                                    result.attachList[i]['checked'] = "Y";
                                } else {
                                    result.attachList[i]['gubun'] = "옵션";
                                    result.attachList[i]['checked'] = "N";
                                }
                            } */
                            AUIGrid.setGridData("#auiGridAttach", result.attachList);
                        }

                        // 기본지급품내역
                        AUIGrid.setGridData("#auiGridBasic", result.basicInfo.basicItemList);
                        var basicItemListDom = $("#basicItemList");
                        basicItemListDom.css("display", "flex");
                        basicItemListDom.html("");
                        var basicDtlBtnDom = $("#basicDtlBtn");
                        basicDtlBtnDom.css("display", "none");
                        if (result.basicInfo.basicItemList) {
                            for (var i = 0; i < result.basicInfo.basicItemList.length; ++i) {
                                basicItemListDom.append("<span>" + result.basicInfo.basicItemList[i].basic_item_name + "</span>");
                            }
                            if (result.basicInfo.basicItemList.length > 0) {
                                basicDtlBtnDom.css("display", "inline-block");
                            }
                        }
                        AUIGrid.setGridData("#auiGridPartFree", result.freeList);
                    }
                }
            );
        }

        function fnChangeOpt() {
            var opt = $M.getValue("opt_code");
            var tempOptList = [];
            for (var i = 0; i < optList.length; ++i) {
                if (optList[i].opt_code == opt) {
                    tempOptList = optList[i].list;
                }
            }
            AUIGrid.setGridData("#auiGridOption", tempOptList);
        }

        function fnHideYn(type) {
            $("." + type).hide();
            return false;
        }

        function fnShowYn(type) {
            $("." + type).show();
            return true;
        }

        function goCustInfoClick() {
            var param = {
                //s_cust_no : $M.getValue("cust_name")
            };
            openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
        }

        function goCustInfo() {
            if ($M.validation(null, {field: ['cust_name']}) == false) {
                return;
            }
            var param = {
                s_cust_no: $M.getValue("cust_name")
            };
            var url = "/comp/comp0301";
            $M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    if (result.success) {
                        $("#cust_name").blur();
                        var list = result.list;
                        switch (list.length) {
                            case 0 :
                                $M.clearValue({field: ["cust_name"]});
                                break;
                            case 1 :
                                var row = list[0];
                                fnSetCustInfo(row)
                                break;
                            default :
                                openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
                                break;
                        }
                    }
                }
            );
        }

        function fnSendMail() {
            var param = {
                'to': $M.getValue('email')
            };
            openSendEmailPanel($M.toGetParam(param));
        }

        function fnSetCustInfo(row) {
            isCust = true;
            $M.goNextPageAjax("/sale/custInfo/" + row.cust_no, "", {method: 'GET'},
                function (result) {
                    if (result.success) {
                        $M.setValue(result);
                        $M.setValue("misu_amt", result.misu_amt);
                        if (result.email) {
                            $M.setValue("email", result.email);
                        }
                        if (result.fax_no) {
                            $M.setValue("fax_no", $M.phoneFormat(result.fax_no));
                        }
                        if (result.tel_no) {
                            $M.setValue("tel_no", $M.phoneFormat(result.tel_no));
                        }
                        if (result.hp_no) {
                            $M.setValue("hp_no", $M.phoneFormat(result.hp_no));
                        }
                    }
                }
            );
        }

        function goSave() {
            if (isMachine == false) {
                alert("모델명을 검색해서 입력해주세요.");
                $("#machine_name").focus();
                return false;
            }
            if (isCust == false) {
                alert("고객명을 검색해서 입력해주세요.");
                $("#cust_name").focus();
                return false;
            }
            if ($M.validation(document.main_form) == false) {
                return;
            }
            var email = $M.getValue("email");
            if (email != "" && !$M.emailCheck(email)) {
                $("#email").focus();
                alert("올바른 이메일을 입력하세요");
                return false;
            }
            var frm = $M.toValueForm(document.main_form);
            var concatCols = [];
            var concatList = [];
            var gridIds = [auiGridBasic, auiGridOption, auiGridAttach, auiGridPart, auiGridPartFree];
            for (var i = 0; i < gridIds.length; ++i) {
                /* if (gridIds[i] == auiGridAttach) {
                    concatList = concatList.concat(AUIGrid.getItemsByValue(gridIds[i], "checked", "Y"));
                } else {
                    concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
                } */
                concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
                concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
            }
            var gridFrm = fnGridDataToForm(concatCols, concatList);
            $M.copyForm(gridFrm, frm);

            $M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method: 'POST'},
                function (result) {
                    console.log(result);
                    if (result.success) {
                        // 여기서 뒤로가기
                        alert("저장이 완료되었습니다.");
                        fnList();
                    }
                }
            );
        }

        function goItemDetailPopup() {
            var param = {
                machine_plant_seq: $M.getValue("machine_plant_seq")
            }
            var poppupOption = "";
            $M.goNextPage('/sale/sale0101p02', $M.toGetParam(param), {popupStatus: poppupOption});
        }

        function fnSetFreeAndPaidMachinePart(list) {
            var row = $.extend(true, [], list);
            for (var i = 0; i < row.parentPaidList.length; ++i) {
                row.parentPaidList[i]['paid_free_yn'] = "N";
            }
            for (var i = 0; i < row.parentFreeList.length; ++i) {
                row.parentFreeList[i]['free_free_yn'] = "Y";
            }
            var freelist = row.parentFreeList;
            freelist.sort($M.sortMulti("-free_add_qty"));
            AUIGrid.setGridData(auiGridPart, row.parentPaidList);
            AUIGrid.setGridData(auiGridPartFree, row.parentFreeList);

            // 유무상 부품계 반영
            $M.setValue("part_cost_amt", AUIGrid.getFooterData(auiGridPart)[1].text);
            $M.setValue("part_free_amt", AUIGrid.getFooterData(auiGridPartFree)[1].text);
            fnChangePrice();
        }

        function fnList() {
            if (openPopupYN == 'Y') {
                window.close();
            }
            $M.goNextPage("/cust/cust010711");
        }

        //그리드생성
        function createAUIGrid() {
            // 그리드 생성_ 기본제공품(화면에 안보임)
            var gridProsBasic = {};
            var columnLayoutBasic = [
                {
                    dataField: "basic_item_name"
                },
                {
                    dataField: "basic_qty"
                },
                {
                    dataField: "basic_machine_plant_seq"
                },
                {
                    dataField: "basic_seq_no"
                }
            ]
            auiGridBasic = AUIGrid.create("#auiGridBasic", columnLayoutBasic, gridProsBasic);
            AUIGrid.setGridData(auiGridBasic, []);
            //그리드 생성 _ 선택사항
            var gridProsOption = {
                rowIdField: "option_part_no",
                height: 60
            };
            var columnLayoutOption = [
                {
                    headerText: "부품번호",
                    dataField: "option_part_no",
                    width: "20%",
                    style: "aui-center",
                },
                {
                    headerText: "부품명",
                    dataField: "option_part_name",
                    style: "aui-left",
                },
                {
                    headerText: "단위",
                    dataField: "option_unit",
                    width: "10%",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == null || value == "" ? "-" : value;
                    }
                },
                {
                    headerText: "구성수량",
                    dataField: "option_qty",
                    width: "10%",
                    style: "aui-center",
                },
                {
                    dataField: "option_machine_plant_seq",
                    visible: false
                }
            ];
            auiGridOption = AUIGrid.create("#auiGridOption", columnLayoutOption, gridProsOption);
            AUIGrid.setGridData(auiGridOption, []);
            $("#auiGridOption").resize();

            //그리드 생성 _ 어테치먼트
            var gridProsAttach = {
                rowIdField: "attach_part_no",
                height: 320,
                rowStyleFunction: function (rowIndex, item) {
                    if (item.attach_check_yn == "Y") {
                        return "aui-row-highlight";
                    }
                    return "";
                }
            };
            var columnLayoutAttach = [
                {
                    headerText: "구분",
                    dataField: "gubun",
                    width: "10%",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        if (item.attach_base_yn == "Y") {
                            return "기본";
                        } else {
                            return "옵션";
                        }
                    }
                },
                {
                    dataField: "attach_base_yn",
                    visible: false
                },
                {
                    headerText: "선택",
                    dataField: "attach_check_yn",
                    width: "10%",
                    style: "aui-center",
                    renderer: {
                        type: "CheckBoxEditRenderer",
                        editable: true,
                        checkValue: "Y",
                        unCheckValue: "N"
                    }
                },
                {
                    headerText: "부품번호",
                    dataField: "attach_part_no",
                    width: "20%",
                    style: "aui-center",
                },
                {
                    headerText: "부품명",
                    dataField: "attach_part_name",
                    width: "30%",
                    style: "aui-left",
                },
                {
                    headerText: "수량",
                    dataField: "attach_qty",
                    style: "aui-center"
                },
                {
                    headerText: "단가",
                    dataField: "attach_part_amt",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                },
                {
                    dataField: "attach_machine_plant_seq",
                    visible: false
                }
            ];
            auiGridAttach = AUIGrid.create("#auiGridAttach", columnLayoutAttach, gridProsAttach);
            AUIGrid.bind(auiGridAttach, "cellEditEnd", function (event) {
                if (event.dataField == "attach_check_yn") {
                    var amt = $M.toNum($M.getValue("attach_amt"));
                    var attachPrice = $M.toNum(event.item.attach_part_amt);
                    var discount = $M.toNum($M.getValue("discount_amt"));
                    var salePrice = $M.toNum($M.getValue("sale_price"));
                    var calcPrice = 0;
                    if (event.value == "N") {
                        calcPrice = amt - attachPrice;
                        $M.setValue("sale_amt", amt - attachPrice);
                    } else {
                        calcPrice = amt + attachPrice;
                        $M.setValue("attach_amt", amt + attachPrice);
                    }
                    ;
                    $M.setValue("sale_amt", salePrice + calcPrice - discount);
                    $M.setValue("attach_amt", calcPrice);
                    fnChangePrice();
                }
            });
            AUIGrid.setGridData(auiGridAttach, []);
            $("#auiGridAttach").resize();

            //그리드 생성 _ 유상
            var gridProsPart = {
                showFooter: true,
                footerPosition: "top",
                rowIdField: "part_no",
                height: 110,
            };
            var columnLayoutPart = [
                {
                    dataField: "paid_machine_basic_part_seq",
                    visible: false
                },
                {
                    dataField: "paid_free_yn",
                    visible: false
                },
                {
                    headerText: "부품번호",
                    dataField: "paid_part_no",
                    width: "20%",
                    style: "aui-left"
                },
                {
                    headerText: "부품명",
                    dataField: "paid_part_name",
                    style: "aui-left",
                },
                {
                    headerText: "수량",
                    dataField: "paid_add_qty",
                    width: "11%",
                    style: "aui-center",
                },
                {
                    headerText: "단가",
                    dataField: "paid_unit_price",
                    width: "15%",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                },
                {
                    headerText: "금액",
                    dataField: "paid_total_amt",
                    width: "15%",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                },
                {
                    dataField: "paid_machine_plant_seq",
                    visible: false
                },
                {
                    dataField: "paid_part_name_change_yn",
                    visible: false
                }
            ];
            // 푸터레이아웃
            var footerColumnLayoutPart = [
                {
                    labelText: "합계",
                    positionField: "paid_part_no"
                }, {
                    dataField: "paid_total_amt",
                    positionField: "paid_total_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                }
            ];

            auiGridPart = AUIGrid.create("#auiGridPart", columnLayoutPart, gridProsPart);
            AUIGrid.setFooter(auiGridPart, footerColumnLayoutPart);
            AUIGrid.setGridData(auiGridPart, []);
            $("#auiGridPart").resize();

            //그리드 생성 _ 무상
            var gridProsPartFree = {
                showFooter: true,
                footerPosition: "top",
                rowIdField: "row",
                height: 110,
                rowStyleFunction: function (rowIndex, item) {
                    if (item.free_add_qty == "0") {
                        // 기본 부품 : 파란색
                        return "aui-row-free-part-default";
                    } else {
                        // 추가 부품 : 검정색
                        return "aui-row-free-part-add";
                    }
                    return "";
                }
            };
            var columnLayoutPartFree = [
                {
                    dataField: "free_machine_basic_part_seq",
                    visible: false
                },
                {
                    dataField: "free_free_yn",
                    visible: false
                },
                {
                    headerText: "부품번호",
                    dataField: "free_part_no",
                    width: "20%",
                    style: "aui-left",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        var retStr = value;
                        if (item.free_free_yn == "Y") {
                            for (var i = 0, len = codeMapCostItemArray.length; i < len; i++) {
                                if (codeMapCostItemArray[i]["code_value"] == value) {
                                    retStr = codeMapCostItemArray[i]["code_name"];
                                    break;
                                }
                            }
                        }
                        return retStr;
                    },
                },
                {
                    headerText: "부품명",
                    dataField: "free_part_name",
                    style: "aui-left",
                },
                {
                    headerText: "추가수량",
                    dataField: "free_add_qty",
                    width: "11%",
                    style: "aui-center",
                },
                {
                    headerText: "기본수량",
                    dataField: "free_default_qty",
                    width: "11%",
                    style: "aui-center",
                },
                {
                    headerText: "단가",
                    dataField: "free_unit_price",
                    width: "10%",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                },
                {
                    headerText: "금액",
                    dataField: "free_total_amt",
                    width: "12%",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right"
                },
                {
                    dataField: "free_machine_plant_seq",
                    visible: false
                },
                {
                    dataField: "free_part_name_change_yn",
                    visible: false
                }
            ];
            // 푸터레이아웃
            var footerColumnLayoutPartFree = [
                {
                    labelText: "합계",
                    positionField: "free_part_no"
                },
                {
                    dataField: "free_total_amt",
                    positionField: "free_total_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer"
                }
            ];

            auiGridPartFree = AUIGrid.create("#auiGridPartFree", columnLayoutPartFree, gridProsPartFree);
            AUIGrid.setGridData(auiGridPartFree, []);
            AUIGrid.setFooter(auiGridPartFree, footerColumnLayoutPartFree);
            $("#auiGridPartFree").resize();
        }

        // 기본 조직도 조회
        function fnSetOrgMapPanel(row) {
            $M.setValue("rfq_org_name", row.org_name);
            $M.setValue("rfq_org_code", row.org_code);
            $M.goNextPageAjax("/rfq/office/" + row.org_code, "", {method: 'GET'},
                function (result) {
                    if (result.success) {
                        var office = {
                            office_post_no : result.post_no,
                            office_addr1 : result.addr1,
                            office_addr2 : result.addr2,
                            office_fax_no : result.fax_no
                        }
                        $M.setValue(office);

                        fnPhoneSetting(result); // 전화번호 셋팅
                    }
                }
            );
        }

        // 견적사업장 전화번호 셋팅
        function fnPhoneSetting(result) {
            // 옵션 초기화
            $("#office_tel_no").children('option').remove();

            // 전화번호 배열 받기
            var originPhoneArr = [result.tel_no, result.service_tel_no, result.part_tel_no];
            var copyPhoneArr = [result.tel_no + " (전화 번호)", result.service_tel_no + " (서비스 담당자 번호)", result.part_tel_no + " (부품/렌탈 담당자 번호)"];

            // 배열 크기만큼 option 생성
            for (var i = 0; i < originPhoneArr.length; i++) {
                if (originPhoneArr[i] != '') { // 배열에 번호가 있다면
                    console.log(originPhoneArr[i]);
                    $("#office_tel_no").append('<option value="' + originPhoneArr[i] + '">' + copyPhoneArr[i] + '</option');
                }
            }
        }

        // 문자발송
        function fnSendSms() {
            var param = {
                'name': $M.getValue('cust_name'),
                'hp_no': $M.getValue('hp_no')
            }
            openSendSmsPanel($M.toGetParam(param));
        }

        function goAddPartPopup() {
            // 모델 검색해야 sale_price가 세팅되므로 0이면 검색안한거로 판단
            if ($M.getValue("sale_price") == "0") {
                alert("모델을 먼저 검색해주세요.");
                $("#machine_name").focus();
                return false;
            }
            parentFreeList = [];
            freeTemp = AUIGrid.exportToObject(auiGridPartFree);
            for (var i = 0; i < freeTemp.length; i++) {
                var obj = new Object();
                for (var prop in freeTemp[i]) {
                    obj[prop.substring(5, prop.length)] = freeTemp[i][prop];
                }
                parentFreeList.push(obj);
            }
            parentPaidList = [];
            paidTemp = AUIGrid.exportToObject(auiGridPart);
            for (var i = 0; i < paidTemp.length; i++) {
                var obj = new Object();
                for (var prop in paidTemp[i]) {
                    obj[prop.substring(5, prop.length)] = paidTemp[i][prop];
                }
                parentPaidList.push(obj);
            }
            var param = {
                'machine_plant_seq': $M.getValue('machine_plant_seq'),
                'page_type': "RFQ"
            };
            openFreeAndPaidMachinePart('fnSetFreeAndPaidMachinePart', $M.toGetParam(param));
        }

        function fnClose() {
            window.close();
        }

    </script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
    <input type="hidden" name="write_price"> <!-- 작성자 전결가 -->
    <input type="hidden" name="review_price"> <!-- 심사자 전결가 -->
    <input type="hidden" name="agree_price"> <!-- 합의자 전결가 -->
    <input type="hidden" name="max_dc_price"> <!-- 할인한도 -->
    <input type="hidden" name="fee_price"> <!-- 수수료 -->
    <input type="hidden" name="cust_no"> <!-- 고객번호 -->
    <input type="hidden" name="rfq_org_code" value="${SecureUser.org_code }"> <!-- 견적발행조직코드 -->
    <input type="hidden" name="rfq_mem_no" value="${SecureUser.mem_no }"><!-- 견적담당자 -->
    <input type="hidden" name="machine_plant_seq">
    <input type="hidden" name="total_amt">

    <div id="auiGridBasic" style="display: none"></div>
    <div class="layout-box" style="min-width: 1450px;">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 상세페이지 타이틀 -->
                <div class="main-title detail">
                    <div class="detail-left">
                        <button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i
                                class="material-iconskeyboard_backspace text-default"></i></button>
                         						<h2>장비 견적서등록</h2>
<%--                        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>--%>
                    </div>
                </div>
                <!-- /상세페이지 타이틀 -->
                <div class="contents" style="min-width: 1440px;">
                    <!-- 탭 -->
                    <ul class="tabs-c">
                        <!-- 장비상세정보에서 넘어온 시퀀스로 탭 구분 -->
<%--                        <c:if test="${(SecureUser.org_type != 'AGENCY') && (inputParam.menu_seq != '3200')}">--%>
<%--                        <c:if test="${(page.fnc.F00606_001 ne 'Y') && (inputParam.menu_seq != '3200')}">--%>
<%--                            <li class="tabs-item">--%>
<%--                                <a href="/cust/cust010702" class="tabs-link">수주</a>--%>
<%--                            </li>--%>
<%--                            <li class="tabs-item">--%>
<%--                                <a href="/cust/cust010704" class="tabs-link">렌탈</a>--%>
<%--                            </li>--%>
<%--                            <li class="tabs-item">--%>
<%--                                <a href="/cust/cust010703" class="tabs-link">정비</a>--%>
<%--                            </li>--%>
<%--                        </c:if>--%>
                        <li class="tabs-item">
                            <a href="/cust/cust010701" class="tabs-link active">장비</a>
                        </li>
                    </ul>
                    <!-- /탭 -->
                    <!-- 상단 폼테이블 -->
                    <div>
                        <table class="table-border">
                            <colgroup>
                                <col width="100px">
                                <col width="">
                                <col width="100px">
                                <col width="">
                                <col width="100px">
                                <col width="">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th class="text-right">견적번호</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-auto">
                                            <input type="text" class="form-control" readonly="readonly" value="">
                                        </div>

                                    </div>
                                </td>
                                <th class="text-right rs">견적일자</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0 width120px calDate rb"
                                               id="rfq_dt" name="rfq_dt" dateFormat="yyyy-MM-dd"
                                               value="${inputParam.s_current_dt}" onchange="javascript:fnSetExpireDt()">
                                    </div>
                                </td>
                                <th class="text-right">업체명</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly="readonly"
                                           id="breg_name" name="breg_name">
                                </td>
                                <th class="text-right">대표자</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly="readonly"
                                           id="breg_rep_name" name="breg_rep_name">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">고객명</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0 width120px" id="cust_name"
                                               name="cust_name" required="required" alt="고객명" readonly="readonly">
                                        <button type="button" class="btn btn-icon btn-primary-gra"
                                                onclick="javascript:goCustInfoClick();"><i
                                                class="material-iconssearch"></i></button>
                                    </div>
                                </td>
                                <th class="text-right rs">휴대폰</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0 width140px rb" id="hp_no"
                                               name="hp_no" format="tel" alt="휴대폰">
                                        <button type="button" class="btn btn-icon btn-primary-gra"
                                                onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i>
                                        </button>
                                    </div>
                                </td>
                                <th class="text-right">사업자번호</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly="readonly" id="breg_no"
                                           name="breg_no">
                                    <input type="hidden" id="breg_seq" name="breg_seq">
                                </td>
                                <th class="text-right">현미수</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right width120px"
                                                   readonly="readonly" id="misu_amt" name="misu_amt" format="decimal">
                                        </div>
                                        <div class="col-1">원</div>
                                    </div>

                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">전화</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly="readonly" id="tel_no"
                                           name="tel_no">
                                </td>
                                <th class="text-right">팩스</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly="readonly" id="fax_no"
                                           name="fax_no">
                                </td>
                                <th class="text-right" rowspan="2">주소</th>
                                <td colspan="3" rowspan="2">
                                    <div class="form-row inline-pd mb7">
                                        <div class="width100px" style="padding-left: 5px; padding-right: 5px">
                                            <input type="text" class="form-control" readonly="readonly" id="post_no"
                                                   name="post_no">
                                        </div>
                                        <div class="col" style="width: calc(100% - 100px)">
                                            <input type="text" class="form-control" readonly="readonly" id="addr1"
                                                   name="addr1">
                                        </div>
                                    </div>
                                    <div class="form-row inline-pd">
                                        <div class="col-12">
                                            <input type="text" class="form-control" readonly="readonly" id="addr2"
                                                   name="addr2">
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">이메일</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col" style="max-width: 200px;">
                                            <input type="text" class="form-control" id="email" name="email">
                                        </div>
                                        <div class="col" style="width: calc(100% - 200px)">
                                            <button type="button" class="btn btn-icon btn-primary-gra"
                                                    onclick="javascript:fnSendMail();"><i
                                                    class="material-iconsmail"></i></button>
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right rs">유효기간</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0 width120px calDate rb"
                                               id="expire_dt" name="expire_dt" required="required" alt="유효기간"
                                               dateFormat="yyyy-MM-dd">
                                    </div>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>

                    <div>
                        <!-- 그리드 타이틀, 컨트롤 영역 -->
                        <div class="title-wrap mt10">
                            <h4>견적사업장</h4>
                        </div>
                        <!-- /그리드 타이틀, 컨트롤 영역 -->

                        <table class="table-border mt5">
                            <colgroup>
                                <col width="100px">
                                <col width="">
                                <col width="100px">
                                <col width="">
                                <col width="100px">
                                <col width="">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th class="text-right">부서</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control width120px border-right-0"
                                               id="rfq_org_name" name="rfq_org_name" value="${SecureUser.org_name }"
                                               readonly="readonly">
                                        <button type="button" class="btn btn-icon btn-primary-gra width120px"
                                                onclick="javascript:openOrgMapPanel('fnSetOrgMapPanel');"><i
                                                class="material-iconssearch"></i></button>
                                    </div>
                                </td>
                                <th class="text-right">견적자</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly="readonly"
                                           id="rfq_mem_name" name="rfq_mem_name" value="${SecureUser.user_name}">
                                </td>
                                <th class="text-right">전화</th>
                                <td>
                                    <select class="form-control width280px" id="office_tel_no" name="office_tel_no">
                                        <c:forEach var="item" items="${origin_office_phone}" varStatus="status">
                                            <option value="${item}">${copy_office_phone[status.index]}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th class="text-right">팩스</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly="readonly"
                                           id="office_fax_no" name="office_fax_no" value="${office_addr.fax_no }">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">주소</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd mb7">
                                        <div class="width100px" style="padding-left: 5px; padding-right:5px;">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   id="office_post_no" name="office_post_no"
                                                   value="${office_addr.post_no}">
                                        </div>
                                        <div class="col" style="width: calc(100% - 110px)">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   id="office_addr1" name="office_addr1" value="${office_addr.addr1}">
                                        </div>
                                    </div>
                                    <div class="form-row inline-pd">
                                        <div class="col">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   id="office_addr2" name="office_addr2" value="${office_addr.addr2}">
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right">특이사항</th>
                                <td colspan="3">
                                    <textarea class="form-control" style="height: 97px; resize: none;" id="memo"
                                              name="memo">${rfq_default_memo}</textarea>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /상단 폼테이블 -->
                    <div class="row">
                        <!-- 하단 좌측 폼테이블-->
                        <div class="col-6">
                            <!-- 견적내역 -->
                            <!-- 그리드 타이틀, 컨트롤 영역 -->
                            <div>
                                <div class="title-wrap mt10">
                                    <h4>견적내역</h4>
                                </div>
                                <!-- /그리드 타이틀, 컨트롤 영역 -->

                                <table class="table-border mt5">
                                    <colgroup>
                                        <col width="85px">
                                        <col width="">
                                        <col width="85px">
                                        <col width="">
                                        <col width="85px">
                                        <col width="">
                                    </colgroup>
                                    <tbody>
                                    <tr>
                                        <th class="text-right rs">견적모델</th>
                                        <td colspan="5">
                                            <div class="input-group" style="width: 150px;">
                                                <input type="text" class="form-control border-right-0 width120px"
                                                       id="machine_name" name="machine_name" required="required"
                                                       alt="모델명" readonly="readonly">
                                                <button type="button" class="btn btn-icon btn-primary-gra"
                                                        onclick="javascript:goModelInfoClick();"><i
                                                        class="material-iconssearch"></i></button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">기준판매가</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-10">
                                                    <input type="text" class="form-control text-right"
                                                           readonly="readonly" id="sale_price" name="sale_price"
                                                           value="0" format="decimal">
                                                </div>
                                                <div class="col-2">원</div>
                                            </div>
                                        </td>
                                        <th class="text-right">무상부품계</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-10">
                                                    <input type="text" class="form-control text-right"
                                                           readonly="readonly" id="part_free_amt" name="part_free_amt"
                                                           value="0" format="decimal">
                                                </div>
                                                <div class="col-2">원</div>
                                            </div>
                                        </td>
                                        <th class="text-right">할인금액</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-10">
                                                    <input type="text" class="form-control text-right" id="discount_amt"
                                                           name="discount_amt" value="0" onchange="fnChangePrice()"
                                                           format="minusNum">
                                                </div>
                                                <div class="col-2">원</div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                        <%--<th class="text-right">대리점가</th>--%>
                                        <th class="text-right">위탁판매점가</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-10">
                                                    <input type="text" class="form-control text-right"
                                                           readonly="readonly" id="agency_price" name="agency_price"
                                                           value="0" format="decimal">
                                                </div>
                                                <div class="col-2">원</div>
                                            </div>
                                        </td>
                                        <th class="text-right">유상부품계</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-10">
                                                    <input type="text" class="form-control text-right"
                                                           readonly="readonly" id="part_cost_amt" name="part_cost_amt"
                                                           value="0" format="decimal" onchange="fnChangePrice()">
                                                </div>
                                                <div class="col-2">원</div>
                                            </div>
                                        </td>
                                        <th class="text-right" rowspan="2">최종판매가</th>
                                        <td rowspan="2">
                                            <div class="form-row inline-pd">
                                                <div class="col-10">
                                                    <!-- 유상 금액이 반영된 최종판매가 -->
                                                    <!-- <input type="text" class="form-control text-right" readonly="readonly" id="sale_amt" name="sale_amt" value="0" format="decimal"> -->
                                                    <input type="text" class="form-control text-right"
                                                           readonly="readonly" id="total_amt" name="total_amt" value="0"
                                                           format="decimal">
                                                </div>
                                                <div class="col-2">원</div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">본사전결가</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-10">
                                                    <!-- ASIS에서 대리점가 = 본사전결가 -->
                                                    <input type="text" class="form-control text-right"
                                                           readonly="readonly" name="agency_price" value="0"
                                                           format="decimal">
                                                </div>
                                                <div class="col-2">원</div>
                                            </div>
                                        </td>
                                        <th class="text-right">어테치먼트계</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-10">
                                                    <input type="text" class="form-control text-right"
                                                           readonly="readonly" id="attach_amt" name="attach_amt"
                                                           value="0" format="decimal" onchange="fnChangePrice()">
                                                </div>
                                                <div class="col-2">원</div>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <!-- /견적내역 -->
                            <!-- 그리드영역 -->
                            <!-- 그리드 타이틀, 컨트롤 영역 -->
                            <div class="title-wrap mt10">
                                <h4>어테치먼트</h4>
                            </div>
                            <!-- /그리드 타이틀, 컨트롤 영역 -->
                            <div id="auiGridAttach" style="margin-top: 5px;"></div>
                            <!-- /그리드영역 -->
                        </div>
                        <!-- /하단 좌측 폼테이블-->
                        <!-- 하단 우측 폼테이블-->
                        <div class="col-6">
                            <!-- 그리드영역 -->
                            <!-- 그리드 타이틀, 컨트롤 영역 -->
                            <div class="title-wrap mt15">
                                <h4>선택사항</h4>
                                <div class="btn-group">
                                    <div class="right">
                                        <select name="opt_code" id="opt_code" style="height: 24px; display: none;"
                                                onchange="fnChangeOpt()"></select>
                                    </div>
                                </div>
                            </div>
                            <!-- /그리드 타이틀, 컨트롤 영역 -->
                            <div id="auiGridOption" style="margin-top: 5px; height: 100px"></div>
                            <!-- /그리드영역 -->
                            <!-- 그리드영역 -->
                            <!-- 그리드 타이틀, 컨트롤 영역 -->
                            <div class="title-wrap mt10">
                                <h4>유상</h4>
                                <div class="btn-group">
                                    <div class="right">
                                        <button type="button" class="btn btn-info"
                                                onclick="javascript:goAddPartPopup();">유/무상부품추가
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <!-- /그리드 타이틀, 컨트롤 영역 -->
                            <div id="auiGridPart" style="margin-top: 5px; height: 150px"></div>
                            <!-- /그리드영역 -->
                            <!-- 그리드영역 -->
                            <!-- 그리드 타이틀, 컨트롤 영역 -->
                            <div class="title-wrap mt10">
                                <h4>무상</h4>
                            </div>
                            <!-- /그리드 타이틀, 컨트롤 영역 -->
                            <div id="auiGridPartFree" style="margin-top: 5px; height: 150px"></div>
                            <!-- /그리드영역 -->
                            <!-- 그리드 타이틀, 컨트롤 영역 -->
                            <div class="title-wrap mt10">
                                <h4>기본지급품목</h4>
                            </div>
                            <!-- /그리드 타이틀, 컨트롤 영역 -->
                            <!-- 기본지급품목내역 -->
                            <div class="boxing vertical-line mt5" id="basicItemList" style="height: 33px;"></div>
                            <!-- /그리드영역 -->

                        </div>
                        <!-- /하단 우측 폼테이블-->
                    </div>
                    <!-- 합계그룹 -->
                    <div class="row inline-pd mt10">
                        <div class="col-2">
                            <table class="table-border">
                                <colgroup>
                                    <col width="40%">
                                    <col width="60%">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-sum">수량</th>
                                    <td class="text-right td-gray">1</td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="col-2">
                            <table class="table-border">
                                <colgroup>
                                    <col width="40%">
                                    <col width="60%">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-sum">금액</th>
                                    <td class="text-right td-gray"><input type="text" class="form-control text-right"
                                                                          readonly="readonly" id="total_amt"
                                                                          name="total_amt" value="0" format="decimal">
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="col-2">
                            <table class="table-border">
                                <colgroup>
                                    <col width="40%">
                                    <col width="60%">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-sum">할인율(%)</th>
                                    <td class="text-right td-gray"><input type="text" class="form-control text-right"
                                                                          id="discount_rate" name="discount_rate"
                                                                          value="0" onchange="fnChangeDCRate()"
                                                                          format="decimal" readonly="readonly"></td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="col-2">
                            <table class="table-border">
                                <colgroup>
                                    <col width="40%">
                                    <col width="60%">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-sum">할인액</th>
                                    <td class="text-right td-gray"><input type="text" class="form-control text-right"
                                                                          id="discount_amt_temp"
                                                                          name="discount_amt_temp" value="0"
                                                                          onchange="fnChangeDCAmt()" format="decimal"
                                                                          readonly="readonly"></td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="col-2">
                            <table class="table-border">
                                <colgroup>
                                    <col width="50%">
                                    <col width="50%">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-sum">부가세</th>
                                    <td class="text-right td-gray"><input type="text" class="form-control text-right"
                                                                          readonly="readonly" id="vat" name="vat"
                                                                          value="0" format="decimal"></td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="col-2">
                            <table class="table-border">
                                <colgroup>
                                    <col width="50%">
                                    <col width="50%">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-sum">총 견적금액</th>
                                    <td class="text-right td-gray">
                                        <div data-tip="(금액-할인액)*VAT"><input type="text" class="form-control text-right"
                                                                            readonly="readonly" id="rfq_amt"
                                                                            name="rfq_amt" value="0" format="decimal">
                                        </div>
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <!-- /합계그룹 -->
                    <!-- 그리드 서머리, 컨트롤 영역 -->
                    <div class="btn-group mt5">
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                <jsp:param name="pos" value="BOM_R"/>
                            </jsp:include>
                        </div>
                    </div>
                    <!-- /그리드 서머리, 컨트롤 영역 -->
                </div>
            </div>
<%--            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>--%>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>

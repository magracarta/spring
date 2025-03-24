<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 매입정산관리 > null > 매입처거래원장상세
-- 작성자 : 황다은
-- 최초 작성일 : 2024-05-23 14:35:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGridTop;
        var auiGridBottom;
        var rowNo = 1;
        var checkYn = "N";
        var dataFieldName = [];

        var lastMonthMisuAmt = 0;
        $(document).ready(function () {
            createAUIGridTop();
            createAUIGridBottom();

            fnInit();
        });

        function fnInit() {
            var params = {
                "s_cust_no" : '${inputParam.s_cust_no}',
                "s_start_dt" : '${inputParam.s_start_dt}',
                "s_end_dt" : '${inputParam.s_end_dt}',
                "__s_misu_yn" : "Y",
            };

            $M.setValue(params);
            goSearch();
        }

        // 거래시필수확인사항
        function fnCheckRequired() {
            var param = {
                "cust_no" : $M.getValue("cust_no")
            };
            openCheckRequiredPanel('setCheckRequired', $M.toGetParam(param));
        }

        // 문자발송
        function fnSendSms() {
            var params = {
                "name" : $M.getValue("cust_name"),
                "hp_no" : $M.getValue("hp_no"),
                "cust_no" : $M.getValue("cust_no"),
                "misu_yn" : "Y",
            };
            openSendSmsPanel($M.toGetParam(params));
        }

        function goSearch() {
            var params = {
                "s_cust_no" : $M.getValue("cust_no"),
                "s_cust_no" : $M.getValue("cust_no"),
                "s_start_dt" : $M.getValue("s_start_dt"),
                "s_end_dt" : $M.getValue("s_end_dt"),
                "detail_yn" : "Y",
                "s_inout_doc_type_cd" : $M.getValue("s_inout_doc_type_cd"),
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : 'GET'},
                function(result) {
                    if(result.success) {
                        fnDataSetting(result);
                        fnDetailList();
                    };
                }
            );
        }

        function fnDataSetting(data) {
            var edMisuAmt = typeof data.monthMisuAmt == "undefined" ? 0 : data.monthMisuAmt;
            lastMonthMisuAmt = $M.toNum(edMisuAmt);

            // 고객정보
            if(data.custInfo != null) {
                $M.setValue(data.custInfo);
                $M.setValue("__s_cust_no", data.custInfo.cust_no);
                $M.setValue("__s_cust_name", data.custInfo.cust_name);
                $M.setValue("__s_hp_no", data.custInfo.hp_no);
                $M.setValue(data.resultSum);
            }

            // 년도별
            AUIGrid.setGridData(auiGridTop, data.list);
            AUIGrid.removeRow(auiGridTop, 0);

            // 상세
            var listDetail = data.listDtl;
            var overAmt = lastMonthMisuAmt;

            for(var i=listDetail.length-1; i>-1; i--) {
                //잔액 = 이월액 + 매출 - 입금 - 매입 + 출금
                if(listDetail[i].cust_no != $M.getValue("cust_no")) {
                    listDetail[i].sale_price = 0;
                    listDetail[i].in_price = 0;
                    listDetail[i].buy_price = 0;
                    listDetail[i].out_price = 0;
                }
                if(listDetail[i].rank_no == 0) {
                    overAmt = $M.toNum(listDetail[i].misu_amt);
                    listDetail[i].over_amt = Math.round(overAmt);
                }
                if(listDetail[i].rank_no == 1) {
                    overAmt = overAmt + $M.toNum(listDetail[i].sale_price) - $M.toNum(listDetail[i].in_price) - $M.toNum(listDetail[i].buy_price) + $M.toNum(listDetail[i].out_price);
                    listDetail[i].over_amt = Math.round(overAmt);
                }
            }

            AUIGrid.setGridData(auiGridBottom, listDetail);

            if(data.custInfo.required_yn == "Y" && checkYn != "Y") {
                // 거래시 필수확인사항 조회
                checkYn = "Y";
                fnCheckRequired();
            }
        }

        // 거래원장 관리용 인쇄 (메모전표 포함)
        function fnBacodePrint() {

            fnPrint("2", AUIGrid.getGridData(auiGridBottom));
        }

        function fnPrint(prt_gubun, detailList) {

            var data = {
                "cust_name" : $M.getValue("cust_name")
                , "breg_name" : $M.getValue("breg_name")
                , "breg_rep_name" : $M.getValue("breg_rep_name")
                , "hp_no" : $M.getValue("hp_no")
                , "tel_no" : $M.getValue("tel_no")
                , "fax_no" : $M.getValue("fax_no")
                , "addr" : $M.getValue("addr")
                , "start_dt" : $M.getValue("s_start_dt")
                , "end_dt" : $M.getValue("s_end_dt")
                , "prt_gubun" : "1"
                , "ed_misu_amt" : $M.getValue("ed_misu_amt")
            };

            var gridEdMisuAmt = detailList[detailList.length-1].over_amt;

            var totalSum = {
                amt1 : $M.getValue("amt1")
                , amt2 : $M.getValue("amt2")
                , amt4 : $M.getValue("amt4")
                , amt5 : $M.getValue("amt5")
                , amt6 : $M.getValue("amt6")
                , amt8 : $M.getValue("amt8")
                // 이월금액 + 매출 - 입금 + 매입 - 출금
                , misu_amt : $M.toNum(gridEdMisuAmt) + $M.toNum($M.getValue("amt3")) - $M.toNum($M.getValue("amt4")) + $M.toNum($M.getValue("amt7")) - $M.toNum($M.getValue("amt8"))
            };

            var param = {
                "data" : data
                , "detail_list" : detailList
                , "total_sum" : totalSum
                , "breg" : JSON.parse('${breg}')
            };

            openReportPanel('cust/cust0106p01_01.crf', param);
        }

        // 엑셀 다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGridBottom, "매입처거래원장 상세내역");
        }

        // 메모추가
        function fnAdd() {
            var item = new Object();
            item.cust_no = $M.getValue("cust_no");
            item.cust_name = $M.getValue("cust_name");
            item.inout_type_cd = "14";  // 메모
            item.inout_dt = $M.getCurrentDate("yyyyMMdd");
            item.inout_doc_type_nm = "";
            item.inout_doc_type_cd = "03";  // 메모
            item.inout_type_name = "메모";
            item.desc_text = "";
            item.row_no = rowNo;

            AUIGrid.addRow(auiGridBottom, item, 'first');

            rowNo++;
        }

        // 그리드 빈값 체크
        function fnCheckGridEmpty() {
            return AUIGrid.validateGridData(auiGridBottom, ["desc_text"], "필수 항목은 반드시 값을 입력해야합니다.");
        }

        // 메모저장
        function goSaveMemo() {
            var gridData = fnChangeGridDataToForm(auiGridBottom);

            if(gridData.length < 1) {
                alert("저장할 메모가 존재하지 않습니다.");
                return;
            }

            $M.goNextPageAjaxSave("cust/cust0106p01/saveMemo", gridData, {method : 'POST'},
                function(result) {
                    if(result.success) {
                        goSearch();
                    };
                }
            );
        }

        // 고객명 변경
        function setCustInfo(data) {
            $M.setValue("cust_no", data.cust_no);
            checkYn = 'N';
            goSearch();
        }

        // 매입처 조회
        function fnSearchClientComm() {
            var param = {};
            openSearchClientPanel("setCustInfo", "comm", $M.toGetParam(param));
        }

        // 관리부품 - 상세내역 팝업
        function fnSelectCustClientPartNoList() {
            var param = {
                "cust_no": $M.getValue("cust_no"),
                "cust_name": $M.getValue("cust_name"),
            };
            var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
            $M.goNextPage('/part/part0301p02', $M.toGetParam(param), {popupStatus: popupOption});
        }

        function createAUIGridTop() {
            var gridPros = {
                showRowNumColumn : false,
                softRemoveRowMode : false,
                showFooter : true,
                footerPosition : "top",
            };

            var columnLayout = [
                {
                    headerText : "년월",
                    dataField : "deal_mon",
                    width : "90",
                    minWidth : "80",
                    editable: true,
                    dataType : "date",
                    formatString : "yyyy-mm"
                },
                {
                    headerText : "고객번호",
                    dataField : "cust_no",
                    visible :false
                },
                {
                    headerText : "매입금",
                    dataField : "buy_amt",
                    dataType : "numeric",
                    formatString : "#,##0",
                    editable: true,
                    width : "150",
                    minWidth : "50",
                    style : "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "출금",
                    dataField : "out_amt",
                    dataType : "numeric",
                    formatString : "#,##0",
                    editable: true,
                    width : "150",
                    minWidth : "50",
                    style : "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "매출금",
                    dataField : "sale_amt",
                    dataType : "numeric",
                    formatString : "#,##0",
                    editable: true,
                    headerStyle : "aui-fold",
                    width : "150",
                    minWidth : "50",
                    style : "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "입금",
                    dataField : "in_amt",
                    dataType : "numeric",
                    formatString : "#,##0",
                    editable: true,
                    headerStyle : "aui-fold",
                    width : "150",
                    minWidth : "50",
                    style : "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "잔액",
                    dataField : "ed_misu_amt",
                    editable: true,
                    dataType : "numeric",
                    formatString : "#,##0",
                    width : "150",
                    minWidth : "60",
                    style : "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "CMD",
                    dataField: "pay_cmd",
                    visible: false
                },
                {
                    headerText : "행순서",
                    dataField : "row_no",
                    visible : false
                },
                {
                    headerText: "고객번호",
                    dataField: "cust_no",
                    visible: false
                }
            ];

            // 푸터 설정
            var footerLayout = [
                {
                    labelText : "계",
                    positionField : "deal_mon"
                },
                {
                    dataField: "buy_amt",
                    positionField: "buy_amt",
                    operation: "SUM",
                    formatString : "#,##0",
                    style: "aui-right aui-footer"
                },
                {
                    dataField: "out_amt",
                    positionField: "out_amt",
                    operation: "SUM",
                    formatString : "#,##0",
                    style: "aui-right aui-footer"
                },
                {
                    dataField: "sale_amt",
                    positionField: "sale_amt",
                    operation: "SUM",
                    formatString : "#,##0",
                    style: "aui-right aui-footer"
                },
                {
                    dataField: "in_amt",
                    positionField: "in_amt",
                    operation: "SUM",
                    formatString : "#,##0",
                    style: "aui-right aui-footer"
                },
                {
                    dataField: "ed_misu_amt",
                    positionField: "ed_misu_amt",
                    operation: "SUM",
                    formatString : "#,##0",
                    style: "aui-right aui-footer",
                    labelFunction : function(value, columnValues, footerValues) {
                        return columnValues[columnValues.length-1];
                    },
                },
            ];

            auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
            // 푸터 레이아웃 세팅
            AUIGrid.setFooter(auiGridTop, footerLayout);
            AUIGrid.setGridData(auiGridTop, []);
            $("#auiGridTop").resize();

            AUIGrid.bind(auiGridTop, "cellClick", function(event) {
                $M.setValue("s_start_dt", event.item.deal_mon + "01");
                $M.setValue("s_end_dt", event.item.deal_mon + $M.getLastDate(event.item.deal_mon));
                $M.setValue("s_cust_no", event.item.cust_no);

                goSearch();
            });

            // 펼치기 전에 접힐 컬럼 목록
            var auiColList = AUIGrid.getColumnInfoList(auiGridTop);
            for (var i = 0; i <auiColList.length; ++i) {
                if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
                    dataFieldName.push(auiColList[i].dataField);
                }
            }

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];
                AUIGrid.hideColumnByDataField(auiGridTop, dataField);
            }
        }

        function createAUIGridBottom() {
            var gridPros = {
                rowIdField : "_$uid",
                showRowNumColumn : true,
                editable : true,
                showFooter : false,
                headerHeight : 20,
                rowHeight : 11,
                footerHeight : 20,
                enableFilter : true,
                rowStyleFunction : function(rowIndex, item) {
                    if(item.rk % 2 == 0 ) {
                        return "aui-grid-row-depth3-style";
                    } else {
                        return "aui-grid-row-white-style";
                    }
                    return null;
                }
            };

            var columnLayout = [
                {
                    headerText : "고객번호",
                    dataField : "cust_no",
                    visible : false
                },
                {
                    headerText : "고객명",
                    dataField : "cust_name",
                    visible : false
                },
                {
                    headerText : "구분코드",
                    dataField : "inout_doc_type_cd",
                    visible : false
                },
                {
                    headerText : "정렬",
                    dataField : "rank_no",
                    visible : false
                },
                {
                    headerText : "행구분",
                    dataField : "rk",
                    visible : false
                },
                {
                    headerText : "행순서",
                    dataField : "row_no",
                    visible : false
                },
                {
                    headerText : "거래구분코드",
                    dataField : "inout_type_cd",
                    visible : false
                },
                {
                    headerText : "월일",
                    dataField : "inout_dt",
                    dataType : "date",
                    formatString : "yy-mm-dd",
                    width : "80",
                    minWidth : "80",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return item.rank_no == "1"? $M.dateFormat($M.toDate(value), 'yy-MM-dd') : "";

                    }
                },
                {
                    headerText : "전표번호",
                    dataField : "inout_doc_no",
                    width : "95",
                    minWidth : "95",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return item.rank_no == "1"? value.substring(4, 16) : "";

                    }
                },
                {
                    headerText : "구분",
                    dataField : "inout_doc_type_nm",
                    width : "60",
                    minWidth : "60",
                },
                {
                    headerText : "종류",
                    dataField : "inout_type_name",
                    width : "60",
                    minWidth : "60",
                    style : "aui-center",
                    styleFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        if (item.inout_type_cd != "16") {
                            return "aui-popup";
                        }
                    }
                },
                {
                    headerText : "내역",
                    width : "405",
                    minWidth : "405",
                    dataField : "desc_text",
                    style : "aui-left"
                },
                {
                    headerText : "수량",
                    dataField : "qty",
                    width : "65",
                    minWidth : "65",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "단가",
                    dataField : "unit_price",
                    dataType : "numeric",
                    formatString : "#,##0",
                    width : "100",
                    minWidth : "100",
                    style : "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        var originCustNo = $M.getValue("cust_no");
                        return  (value == "" || value == null || item.cust_no != originCustNo) ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "매입",
                    dataField : "buy_price",
                    dataType : "numeric",
                    formatString : "#,##0",
                    style : "aui-right",
                    width : "100",
                    minWidth : "100",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        var originCustNo = $M.getValue("cust_no");
                        return  (value == "" || value == null || item.cust_no != originCustNo) ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "출금",
                    dataField : "out_price",
                    dataType : "numeric",
                    formatString : "#,##0",
                    style : "aui-right",
                    width : "100",
                    minWidth : "100",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        var originCustNo = $M.getValue("cust_no");
                        return  (value == "" || value == null || item.cust_no != originCustNo) ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "매출(VAT)",
                    dataField : "sale_price",
                    dataType : "numeric",
                    formatString : "#,##0",
                    style : "aui-right",
                    width : "100",
                    minWidth : "100",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        var originCustNo = $M.getValue("cust_no");
                        return  (value == "" || value == null || item.cust_no != originCustNo) ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "입금",
                    dataField : "in_price",
                    dataType : "numeric",
                    formatString : "#,##0",
                    style : "aui-right",
                    width : "100",
                    minWidth : "100",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        var originCustNo = $M.getValue("cust_no");
                        return  (value == "" || value == null || item.cust_no != originCustNo) ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "잔액",
                    dataField : "over_amt",
                    dataType : "numeric",
                    formatString : "#,##0",
                    style : "aui-right",
                    width : "100",
                    minWidth : "100",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText : "비고",
                    dataField : "dis_remark",
                    style : "aui-left",
                    width : "200",
                    minWidth : "200",
                },
                {
                    headerText : "고객쿠폰번호",
                    dataField : "cust_coupon_no",
                    visible : false
                }
            ];

            auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
            // 푸터 레이아웃 세팅
            AUIGrid.setGridData(auiGridBottom, []);

            AUIGrid.bind(auiGridBottom, "cellEditBegin", function (event) {
                // 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
                if (AUIGrid.isAddedById(event.pid, event.item._$uid) && event.dataField == "desc_text") {
                    return true;
                } else {
                    return false;
                }
            });

            $("#auiGridBottom").resize();

            AUIGrid.bind(auiGridBottom, "cellClick", function(event) {
                if(event.dataField == "inout_type_name" && event.item.inout_type_name != null) {
                    var inoutDocTypeCd = event.item.inout_doc_type_cd;
                    var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
                    var params = {
                        "inout_doc_no" : event.item.inout_doc_no
                    };

                    if(inoutDocTypeCd == "00" || inoutDocTypeCd == "09") {
                        $M.goNextPage('/cust/cust0203p01', $M.toGetParam(params), {popupStatus : popupOption}); // 입출금전표 상세
                    } else if(inoutDocTypeCd == "05" || inoutDocTypeCd == "07" || inoutDocTypeCd == "11" || inoutDocTypeCd == "13") {
                        $M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption}); // 매출처리 상세
                    } else if(inoutDocTypeCd == "06") {
                        if(event.item.inout_type_cd == "01") {
                            $M.goNextPage('/cust/cust0203p01', $M.toGetParam(params), {popupStatus : popupOption}); // 입출금전표 상세
                        } else {
                            params.cust_coupon_no = event.item.cust_coupon_no;
                            $M.goNextPage("/cust/cust0305p01", $M.toGetParam(params), {popupStatus : popupOption});	// 쿠폰처리 상세
                        }
                    } else if(inoutDocTypeCd == "08") {
                        $M.goNextPage('/sale/sale0101p08', $M.toGetParam(params), {popupStatus : popupOption}); // 출하의뢰서
                    } else if(inoutDocTypeCd == "02" || inoutDocTypeCd == "10") {
                        $M.goNextPage('/part/part0302p01', $M.toGetParam(params), {popupStatus : popupOption}); // 매입처리
                    } else if(inoutDocTypeCd == "03") {
                        $M.goNextPage('/cust/cust0106p04', $M.toGetParam(params), {popupStatus : popupOption}); // 메모팝업
                    } else if(inoutDocTypeCd == "17"){
                        $M.goNextPage('/cust/cust0306p02', $M.toGetParam(params), {popupStatus : popupOption}); // 마일리지전표상세팝업
                    }
                }
            });
        }

        function fnDetailList() {
            if($("#detail_list").is(":checked")){
                AUIGrid.clearFilterAll(auiGridBottom);
            }else{
                AUIGrid.setFilter(auiGridBottom, "inout_type_name",  function(dataField, value, item) {
                    if (item.desc_text == "이월금액") {
                        return true;
                    }
                    return value != null ? true : false; // 값이 있는것만 출력
                });
            }
        }

        // 2024.07.31 자동화 추가개발_추가요청으로 매출/입금 default로 안보이게
        function fnChangeColumn(event) {
            var data = AUIGrid.getGridData(auiGridTop);
            var target = event.target || event.srcElement;
            if(!target)	return;

            var dataField = target.value;
            var checked = target.checked;

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];

                if(checked) {
                    AUIGrid.showColumnByDataField(auiGridTop, dataField);
                } else {
                    AUIGrid.hideColumnByDataField(auiGridTop, dataField);
                }
            }
        }


    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" id="cust_no" name="cust_no" value="${inputParam.s_cust_no}">
    <input type="hidden" id="__s_cust_no" name="__s_cust_no">
    <input type="hidden" id="__s_cust_name" name="__s_cust_name">
    <input type="hidden" id="__s_hp_no" name="__s_hp_no">
    <div class="popup-wrap width-100per">
        <!-- contents 전체 영역 -->
        <!-- 메인 타이틀 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /메인 타이틀 -->
        <div class="content-wrap">
            <div class="title-wrap">
                <h4>거래원장상세</h4>
                <div class="form-row inline-pd">
                    <div class="btn-group">
                        <div class="right">
                            <label for="s_toggle_column" style="color:black;">
                                <input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
                            </label>
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row mt5">
                <div class="col-6">
                    <!-- 검색영역 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="70px">
                                <col width="260px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회기간</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="시작일" value="${inputParam.s_start_dt}">
                                            </div>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="종료일" value="${inputParam.s_end_dt}">
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td class="">
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                                <td class="right" style="width: 100px;">
                                    <input type="checkbox" id="detail_list" name="detail_list" checked="checked" onclick="javascript:fnDetailList();"><label for="detail_list">세부내역</label>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <div class="mt10">
                        <table class="table-border" style="height: 322px">
                            <colgroup>
                                <col width="90px">
                                <col width="">
                                <col width="90px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th class="text-right">고객명</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control width150px" id="cust_name" name="cust_name" readonly="readonly">
                                        <c:if test="${page.fnc.F05783_001 eq 'Y'}">
                                            <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
                                        </c:if>
                                    </div>
                                </td>
                                <th class="text-right">대표자</th>
                                <td>
                                    <input type="text" class="form-control width150px" id="breg_rep_name" name="breg_rep_name" readonly="readonly">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">업체명</th>
                                <td>
                                    <input type="text" class="form-control width150px" id="breg_name" name="breg_name" readonly="readonly">
                                </td>
                                <th class="text-right">휴대폰</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0" id="hp_no" name="hp_no" readonly="readonly" format="phone">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">전화번호</th>
                                <td>
                                    <input type="text" class="form-control width150px" id="tel_no" name="tel_no" readonly="readonly">
                                </td>
                                <th class="text-right">팩스</th>
                                <td>
                                    <input type="text" class="form-control width150px" id="fax_no" name="fax_no" readonly="readonly">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">주소</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd">
                                        <div class="col-2"><input type="text" class="form-control" id="post_no" name="post_no" readonly="readonly"></div>
                                        <div class="col-10"><input type="text" class="form-control" id="addr" name="addr" readonly="readonly"></div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">업체그룹</th>
                                <td>
                                    <input type="text" id="com_buy_group_desc" name="com_buy_group_desc" class="form-control width180px" readonly="readonly">
                                </td>
                                <th class="text-right">매입구분</th>
                                <td>
                                    <input type="text" class="form-control width80px" readonly="readonly" value = "${result.nation_type_df == 'D'? '외자' : '내자'}">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">지불조건</th>
                                <td>
                                    <input type="text" id="out_case_name" name="out_case_name" class="form-control width80px" readonly="readonly">
                                </td>
                                <th class="text-right">관리부품</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-4">
                                            <input type="text" class="form-control width120px" id="mng_part_cnt" name="mng_part_cnt" value="${result.mng_part_cnt}" readonly="readonly" format="decimal">
                                        </div>
                                        <div class="col-6">
                                            <button type="button" class="btn btn-primary-gra" style="width: 80px;" onclick="javascript:fnSelectCustClientPartNoList();">상세내역</button>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">거래외환</th>
                                <td>
                                    <input type="text" id="money_unit_cd" name="money_unit_cd" class="form-control width60px" readonly="readonly">
                                </td>
                                <!-- 이월금액은 from의 전년도 이월금액으로 from년도00월 조회. (구전산부터 그랬음) -->
                                <th class="text-right">이월금액</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width130px">
                                            <input type="text" class="form-control width120px text-right" id="ed_misu_amt" name="ed_misu_amt" readonly="readonly" format="decimal">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>

                </div>
                <!-- 그리드 영역 -->
                <div class="col-6" style="padding: 0">
                    <div id="auiGridTop" style="margin-top: 4px; height: 370px;"></div>

                </div>
                <!-- /그리드 영역 -->
            </div>
            <!-- /상단 폼테이블 -->
            <!-- 그리드 타이틀, 컨트롤 영역 -->
            <div class="title-wrap mt10">
                <h4>상세내역</h4>
                <div class="btn-group">
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                    </div>
                </div>
            </div>
            <!-- /그리드 타이틀, 컨트롤 영역 -->
            <!-- 하단 그리드영역 -->
            <div id="auiGridBottom" style="margin-top: 5px; height: 400px;"></div>
            <!-- /하단 그리드영역 -->
            <!-- 합계그룹 -->
            <div class="row inline-pd mt10">
                <div class="col" style="width: 12%;">
                    <table class="table-border">
                        <colgroup>
                            <col width="40%">
                            <col width="60%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right th-sum">매출</th>
                            <td class="text-right"><input type="text" class="form-control width120px text-right" id="amt1" name="amt1" readonly="readonly" format="decimal"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col" style="width: 12%;">
                    <table class="table-border">
                        <colgroup>
                            <col width="40%">
                            <col width="60%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right th-sum">VAT</th>
                            <td class="text-right"><input type="text" class="form-control width120px text-right" id="amt2" name="amt2" readonly="readonly" format="decimal"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col" style="width: 12%;">
                    <table class="table-border">
                        <colgroup>
                            <col width="40%">
                            <col width="60%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right th-sum">합계</th>
                            <td class="text-right"><input type="text" class="form-control width120px text-right" id="amt3" name="amt3" readonly="readonly" format="decimal"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col" style="width: 12%;">
                    <table class="table-border">
                        <colgroup>
                            <col width="40%">
                            <col width="60%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right th-sum">입금</th>
                            <td class="text-right"><input type="text" class="form-control width120px text-right" id="amt4" name="amt4" readonly="readonly" format="decimal"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col" style="width: 12%;">
                    <table class="table-border">
                        <colgroup>
                            <col width="40%">
                            <col width="60%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right th-sum">매입</th>
                            <td class="text-right"><input type="text" class="form-control width120px text-right" id="amt5" name="amt5" readonly="readonly" format="decimal"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col" style="width: 12%;">
                    <table class="table-border">
                        <colgroup>
                            <col width="40%">
                            <col width="60%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right th-sum">VAT</th>
                            <td class="text-right"><input type="text" class="form-control width120px text-right" id="amt6" name="amt6" readonly="readonly" format="decimal"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col" style="width: 12%;">
                    <table class="table-border">
                        <colgroup>
                            <col width="40%">
                            <col width="60%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right th-sum">합계</th>
                            <td class="text-right"><input type="text" class="form-control width120px text-right" id="amt7" name="amt7" readonly="readonly" format="decimal"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col" style="width: 12%;">
                    <table class="table-border">
                        <colgroup>
                            <col width="40%">
                            <col width="60%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right th-sum">출금</th>
                            <td class="text-right"><input type="text" class="form-control width120px text-right" id="amt8" name="amt8" readonly="readonly" format="decimal"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- /합계그룹 -->
        </div>
    </div>
    <!-- /contents 전체 영역 -->
</form>
</body>
</html>
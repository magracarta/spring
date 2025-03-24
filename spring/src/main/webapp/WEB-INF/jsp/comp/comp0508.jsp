<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 가격조건표(메인)
-- 작성자 : 정재호
-- 최초 작성일 : 2021-08-06 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <style type="text/css">

        /* 커스텀 행 스타일 ( 세로선 ) */
        .my-column-style {
            border-right: 1px solid #000000 !important;
        }

    </style>
    <script type="text/javascript">
        var auiGrid;
        var hasAuth = "${hasAuth}";
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
        var orgGubun = "${org_gubun}";
        var hideColumnList = []; // 사용자 부서에 따른 컬럼 숨김 항목

        $(document).ready(function () {
            createAUIGrid();
            goSearch();
        });

        /////////////////////// 기본 메서드 //////////////////////

        /**
         * 판매가격 레이아웃 생성
         * @returns {}
         */
        function createSaleLayout() {
            var saleColumnLayout =
                {
                    headerText: "판매가격",
                    children: [
                        {
                            dataField: "base_pro_sale_price",
                            headerText: "프로모션가</br>(본사)",
                            width: "100",
                            minWidth: "50",
                            editable: false,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? value : $M.setComma(value);
                            },
                        },
                        {
                            dataField: "agency_pro_sale_price",
                            // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
                            // headerText: "프로모션가</br>(대리점)",
                            headerText: "프로모션가</br>(위탁판매점)",
                            width: "100",
                            minWidth: "50",
                            editable: false,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? value : $M.setComma(value);
                            },
                        },
                        {
                            dataField: "min_sale_price",
                            headerText: "최저판매가격",
                            width: "100",
                            minWidth: "50",
                            editable: false,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? value : $M.setComma(value);
                            },
                        },
                        {
                            dataField: "agency_min_sale_price",
                            // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
                            // headerText: "대리점공급가",
                            headerText: "위탁판매점공급가",
                            width: "100",
                            minWidth: "50",
                            editable: false,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? value : $M.setComma(value);
                            },
                        },
                        {
                            dataField: "list_sale_price",
                            headerText: "판매가격",
                            headerStyle: "my-column-style",
                            width: "100",
                            minWidth: "50",
                            editable: false,
                            style: "my-column-style",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? value : $M.setComma(value);
                            },
                        },
                        {
                            dataField: "old_list_sale_price",
                            headerText: "이전가격",
                            headerStyle : "aui-fold",
                            width: "100",
                            minWidth: "50",
                            style: "aui-popup",
                            editable: false,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? value : $M.setComma(value);
                            },
                        },
                    ],
                    style: "my-column-style",
                    headerStyle: "my-column-style",
                };

            return saleColumnLayout;
        }

        /**
         * 기본 지급품 레이아웃 생성
         * @param itemGList 기본 지급품 리스트
         * @returns 레이아웃 obj
         */
        function createItemGLayout(itemGList) {
            var itemGColumnLayout = {
                headerText: "기본 지급품",
                children: [],
                style: "my-column-style",
                headerStyle: "my-column-style",
            };

            if (itemGList != null) {
                for (var i = 0; i < itemGList.length; i++) {
                    var col;

                    if (i == (itemGList.length - 1)) { // 마지막 순번 (세로선을 위해)
                        col = {
                            dataField: "item_code_" + itemGList[i].item_code,
                            headerText: itemGList[i].item_name,
                            editable: false,
                            style: "aui-popup my-column-style",
                            headerStyle: "my-column-style",
                            width: 80,
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                if (value != "0") { // 이미지 데이터가 있다면 [보기] 텍스트 출력
                                    return '보기';
                                }
                                return "";
                            },
                            styleFunction: function () {
                                return "aui-popup my-column-style"
                            }
                        }
                    } else {
                        col = {
                            dataField: "item_code_" + itemGList[i].item_code,
                            headerText: itemGList[i].item_name,
                            width: 80,
                            styleFunction: function () {
                                if (hasAuth == "Y") {
                                    return 'aui-editable';
                                } else {
                                    return 'aui-center';
                                }
                            }
                        }
                    }
                    itemGColumnLayout.children.push(col);
                }
            }
            return itemGColumnLayout;
        }

        /**
         * 기본 장착 / 옵션금액 레이아웃 생성
         * @param itemAList 기본 장착 리스트
         * @returns 레이아웃 obj
         */
        function createItemALayout(itemAList) {
            var itemAColumnLayout = {
                headerText: "기본장착 / 옵션금액",
                children: [],
                style: "my-column-style",
                headerStyle: "my-column-style",
            };

            if (itemAList != null && itemAList.length != 0) { // 데이터가 있다면

                for (var i = 0; i < itemAList.length; i++) { // 헤더 레이아웃 생성
                    var col;

                    if (i == (itemAList.length - 1)) { // 마지막 순번 (세로선을 위해)
                        col = {
                            dataField: "item_code_" + itemAList[i].item_code,
                            headerText: itemAList[i].item_name,
                            style: "my-column-style",
                            headerStyle: "my-column-style",
                            width: 80,
                            styleFunction: function () {
                                if (hasAuth == "Y") {
                                    return 'aui-editable';
                                } else {
                                    return 'aui-center';
                                }
                            }
                        }
                    } else {
                        col = {
                            dataField: "item_code_" + itemAList[i].item_code,
                            headerText: itemAList[i].item_name,
                            width: 80,
                            styleFunction: function () {
                                if (hasAuth == "Y") {
                                    return 'aui-editable';
                                } else {
                                    return 'aui-center';
                                }
                            }
                        }
                    }

                    itemAColumnLayout.children.push(col);
                }
            } else { // 데이터가 없다면
                itemAColumnLayout.children.push(
                    {
                        style: "my-column-style",
                        headerStyle: "my-column-style",
                        width: 110,
                        editable: false,
                    }
                );
            }
            return itemAColumnLayout;
        }

        /**
         * 최종 레이아웃 생성 (기본 default 레이아웃 포함)
         * @param result 최종 레이아웃
         * @returns 레이아웃 obj
         */
        function getResultLayout(result) {

            // 비고 레이아웃
            var remark = {
                dataField: "remark",
                headerText: "비고",
                width: 130,
                styleFunction: function () {
                    if (hasAuth == "Y") {
                        return 'aui-editable';
                    } else {
                        return 'aui-center';
                    }
                }
            }

            var resultColumnLayout = [
                {
                    dataField: "maker_cd",
                    headerText: "메이커 코드",
                    visible: false
                },
                {
                    dataField: "maker_name",
                    headerText: "메이커",
                    width: "55",
                    minWidth: "45",
                    editable: false,
                },
                {
                    dataField: "machine_name",
                    headerText: "모델",
                    width: "100",
                    minWidth: "100",
                    style: "aui-popup",
                    editable: false,
                }
            ];

            // 권한없는 부서의 경우 판매가격 숨기기
            if (orgGubun != "") {
                resultColumnLayout.push(createSaleLayout()); // 판매가격 레이아웃 추가
            }
            resultColumnLayout.push(createItemGLayout(result.itemGList)); // 기본 지급품 추가
            resultColumnLayout.push(createItemALayout(result.itemAList)); // 기본장착, 옵션 금액 추가
            resultColumnLayout.push(remark); // 비고란

            return resultColumnLayout;
        }

        ////////////////////////////////////////////////////////

        ///////////////// 그룹 그리드 이벤트 메서드 ////////////////

        // AUIGrid 를 생성합니다.
        function createAUIGrid() {

            var auiGridProps = {
                rowIdField: "machine_plant_seq",
                showStateColumn: true,
                height: 600,
                headerHeight: 40,
            };

            if (hasAuth == "Y") {
                auiGridProps.editable = true;
            } else {
                auiGridProps.editable = false;
            }

            auiGrid = AUIGrid.create("#auiGrid", [], auiGridProps);

            // 셀 클릭 이벤트
            AUIGrid.bind(auiGrid, "cellClick", auiCellClickHandler);
        };

        function auiCellClickHandler(event) {
            switch (event.dataField) {
                case 'machine_name':
                    var param = {
                        machine_plant_seq: event.item.machine_plant_seq,
                        machine_name: event.item.machine_name
                    }
                    $M.goNextPage('/comp/comp0508p01', $M.toGetParam(param), {popupStatus: ""});
                    break;
                case 'old_list_sale_price':
                    if (event.value !== "") { // != 으로 비교시 [0 != ""]이 false로 나와서 !==로 비교
                        var param = {
                            machine_plant_seq: event.item.machine_plant_seq
                        }
                        $M.goNextPage('/sale/sale0206p02', $M.toGetParam(param), {popupStatus: ""});
                    }
                    break;
                case "item_code_img":
                    if (event.value != "") { // 이미지 갯수가 있다면 클릭 이벤트 발생
                        var param = {
                            machine_plant_seq: event.item.machine_plant_seq
                        }
                        $M.goNextPage('/sale/sale0101p02', $M.toGetParam(param), {popupStatus: ""});
                    }
                    break;
            }
        }

        ////////////////////////////////////////////////////////

        /////////////////////// 버튼 메서드 //////////////////////

        // 조회 버튼
        function goSearch() {
            var param = {
                "s_maker_cd": $M.getValue('s_maker_cd'),
                "s_machine_name": $M.getValue('s_machine_name'),
                "org_gubun": orgGubun,
            }

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
                function (result) {
                    $("#total_cnt").html(result.total_cnt);
                    AUIGrid.changeColumnLayout(auiGrid, getResultLayout(result));
                    AUIGrid.setGridData(auiGrid, result.priceList);

                    // [15127] 계정권한에 따른 판매가격 노출 구분 - 김경빈
                    switch (orgGubun) {
                        case 'SERV':
                            // 서비스 계정 - 프로모션가(대리점), 대리점공급가 컬럼 숨기기
                            hideColumnList = ["agency_pro_sale_price", "agency_min_sale_price"];
                            AUIGrid.hideColumnByDataField(auiGrid, hideColumnList);
                            break;
                        case 'AGENCY':
                            // 대리점 계정 - 프로모션가(본사), 최저판매가격 컬럼 숨기기
                            hideColumnList = ["base_pro_sale_price", "min_sale_price"];
                            AUIGrid.hideColumnByDataField(auiGrid, hideColumnList);
                            break;
                        case 'SALE':
                            // 영업 계정 - 모두 보이기
                            hideColumnList = [];
                            break;
                    }

                    // 펼치기 전에 접힐 컬럼 목록
        			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
        			for (var i = 0; i <auiColList.length; ++i) {
        				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
        					dataFieldName.push(auiColList[i].dataField);
        				}
        			}
        			if($("input:checkbox[id='s_toggle_column']").is(":checked") == false){
        				for (var i = 0; i < dataFieldName.length; ++i) {
            				var dataField = dataFieldName[i];
            				AUIGrid.hideColumnByDataField(auiGrid, dataField);
            			}
        			}
                }
            );
        }

        // 엔터 이벤트
        function enter(fieldObj) {
            var field = ["s_machine_name", "s_maker_cd"];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch();
                }
            });
        }

        // 엑셀 다운로드
        function fnDownloadExcel() {
            var exportProps = {
                // 엑셀 다운로드 시, 부서에 따른 컬럼 제거 - 김경빈
                exceptColumnFields : hideColumnList
            }
            fnExportExcel(auiGrid, "판매가격조건표", exportProps);
        }

        // 저장 버튼
        function goSave() {
            var changeCnt = fnChangeGridDataCnt(auiGrid);
            if (changeCnt == 0) {
                alert("변경사항이 없습니다.");
                return;
            }

            var editeRowItems = AUIGrid.getEditedRowColumnItems(auiGrid); // 변경된 데이터
            var list = [];

            for (var i = 0; i < editeRowItems.length; i++) {
                var keys = Object.keys(editeRowItems[i]); // 변경된 데이터 Key값 리스트
                var values = Object.values(editeRowItems[i]); // 변경된 데이터 value값 리스트
                var seq = values[0]; // 현재 배열의 시퀀스

                for (var j = 1; j < keys.length; j++) {
                    var key = keys[j];
                    var value = values[j];

                    if (key == "remark") { // 비고 데이터 오브젝트 (SaleCond DB)
                        var param = {
                            mt_machine_plant_seq: seq,
                            remark: value
                        }
                        list.push(param);
                    } else { // 상세 데이터 오브젝트 (SaleCondDtl DB)
                        itemCode = key.substring(10, 12);
                        var param = {
                            machine_plant_seq: seq,
                            item_code: itemCode,
                            item_value: value,
                        }
                        list.push(param);
                    }
                }
            }

            var objForm = $M.jsonArrayToForm(list);
            $M.setValue(objForm, "s_maker_cd", $M.getValue("s_maker_cd"));
            $M.goNextPageAjax(this_page + "/save", objForm, {method: 'post'}, function (result) {
                if (result.success) {
                    goSearch();
                }
            });
        }

     	// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
                    // 펼침 체크 시 스타일 변경
                    AUIGrid.setColumnPropByDataField(auiGrid, "old_list_sale_price", {headerStyle : "aui-fold my-column-style", style: "aui-popup my-column-style"});
                    AUIGrid.setColumnPropByDataField(auiGrid, "list_sale_price", {headerStyle : "", style: ""});
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
                    // 펼침 미체크 시 스타일 변경
                    AUIGrid.setColumnPropByDataField(auiGrid, "list_sale_price", {headerStyle : "my-column-style", style: "my-column-style"});
				}
			}

 		    // 구해진 칼럼 사이즈를 적용 시킴.
			/* var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    AUIGrid.setColumnSizeList(auiGrid, colSizeList); */
		}

        // 닫기 버튼
        function fnClose() {
            window.close();
        }

        ////////////////////////////////////////////////////////


    </script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <!-- 컨텐츠 영역 -->
        <div class="content-wrap">
            <!-- 기본 -->
            <div class="search-wrap">
                <table class="table">
                    <colgroup>
                        <col width="50px">
                        <col width="150px">
                        <col width="50px">
                        <col width="150px">
                        <col width="*">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th>메이커</th>
                        <td>
                            <select class="form-control" id="s_maker_cd" name="s_maker_cd">
                                <c:forEach var="item" items="${makerList}">
                                    <option value="${item.maker_cd}">${item.maker_name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <th>모델명</th>
                        <td>
                            <input type="text" class="form-control width120px" id="s_machine_name"
                                   name="s_machine_name">
                        </td>
                        <td class="">
                            <button type="button" class="btn btn-important" style="width: 50px;"
                                    onclick="javascript:goSearch();">조회
                            </button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /기본 -->
            <div class="title-wrap mt10">
                <h4>조회결과</h4>
                <div class="btn-group">
                    <div class="right dpf">
                        <p class="text-warning mr5">• 최근 한달내 가격 업데이트시 주황색 표시</p>
                        <!-- 판매가격 볼 수 없는 부서의 경우 '펼침' 버튼 숨김 -->
                        <c:if test="${org_gubun eq 'SERV' || org_gubun eq 'SALE' || org_gubun eq 'AGENCY'}">
                            <label for="s_toggle_column" style="color:black; margin-right:3px;">
                                <input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
                            </label>
                        </c:if>
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                            <jsp:param name="pos" value="TOP_R"/>
                        </jsp:include>
                    </div>
                </div>
            </div>
            <div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>
            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt5">
                <div class="left">
                    총 <strong class="text-primary" id="total_cnt">0</strong>건
                </div>
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
        <!-- /컨텐츠 영역 -->

    </div>
    <!-- /팝업 -->
</form>
</body>
</html>

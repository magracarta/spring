<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 수주잔고 > null > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-02-28 18:17:34
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

        let auiGrid;    // 조회결과 그리드
        let auiGridArea; // 영업지역 및 센터 그리드
		let dateList = ${dateList}; // 조회년월 리스트
        let hideList = ["a_total_rate"]; // 펼침 항목
        let areaList;   // 조회한 영업지역
        let sMemNo;     // 조회한 직원번호
        let sStartDt;   // 조회 시작연월
        let sEndDt;     // 조회 끝연월

		$(document).ready(function() {
			createAUIGrid();
            createAUIGridArea();
			goSearch();
		});

        // 조회
		function goSearch() {

            // 체크된 지역
			const areaGridData = AUIGrid.getCheckedRowItemsAll(auiGridArea);

			if (areaGridData.length <= 0) {
				alert("마케팅지역을 1곳 이상 선택해주세요.");
				return;
			}

            areaList = $M.getArrStr(areaGridData.map(data => data.sale_area_code));
            sMemNo = $M.getValue("s_mem_no");

            // 조회년월
            const endMon = $M.getValue("s_end_mon").length === 1 ? '0' + $M.getValue("s_end_mon") : $M.getValue("s_end_mon");
            sEndDt = $M.getValue("s_end_year") + endMon;

			const param = {
				s_start_dt : sEndDt,
				s_area_code_str : areaList,
				s_mem_no : sMemNo,
                s_org_code : $M.getValue("s_org_code"),
                s_gubun : $M.getValue("s_gubun"),
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if (result.success) {
						dateList = result.dateList;
                        sStartDt = dateList[dateList.length - 1];
                        sEndDt = dateList[0];
                        destroyGrid();
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

		// '조회결과' 그리드생성
		function createAUIGrid() {

			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: false, // 행 줄번호(로우 넘버링) 칼럼의 출력 여부를 지정
				enableCellMerge : true, // 셀 병합
				enableSummaryMerge : true, // 그룹핑 합계 필드(소계) 셀 가로 병합 실행 여부를 지정
				summaryMergePolicy : "all", // 그룹핑 필드 지정 개수 만큼 병합 실행
                // [23426] 총계 틀 고정
                fixedRowCount : 1,

				// 그리드 ROW 스타일 함수 정의
				rowStyleFunction : function(rowIndex, item) {
					if (item.machine_name.includes("소계") || item.machine_name.includes("합계") || item.machine_name.includes("총계")) {
						return "aui-grid-row-depth3-style";
					}
					return null;
				},
			};

			var columnLayout = [
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "5%",
					cellMerge : true, // 셀 세로 병합 실행
					// cellColMerge : true, // 셀 가로 병합 실행 >>> 가로 병합하면 hideColumn 안됨
					style : "aui-center",
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "10%",
					style : "aui-center",
				},
				{
					headerText: "기간내",
					children: [
						{
							headerText: "수량",
							dataField: "a_total_qty",
							width : "5%",
                            style : "aui-popup",
							labelFunction : myLabelFunction
						},
						{
							dataField: "a_total_rate",
							headerText: "비율",
							postfix: "%",
							headerStyle : "aui-fold",
							width : "5%",
							style: "aui-center",
						}
					]
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					dataField : "maker_cd",
					visible : false
				},
                {
                    dataField: "maker_weight_type",
                    visible: false
                }
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

            dateList.forEach(date => {
				const qtyDataField = "a_" + date + "_qty";
				const rateDataField = "a_" + date + "_rate";
				const columnObj = {
					headerText : String(date).slice(0, 4) + '-' + String(date).slice(4, 6),
					children : [
						{
							headerText : "수량",
							dataField : qtyDataField,
							width : "5%",
                            style : "aui-popup",
							labelFunction : myLabelFunction,
						},
						{
							headerText : "비율",
							dataField : rateDataField,
							headerStyle : "aui-fold",
							postfix : "%",
							width : "5%",
							style : "aui-center",
						}
					]
				};

				AUIGrid.addColumn(auiGrid, columnObj, 'last');

                // 비율 dataField '숨김' 리스트에 추가
                if (!hideList.includes(rateDataField)) {
                  hideList.push(rateDataField);
                }
            });

			$("#auiGrid").resize();

            // 셀 클릭 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellClick", function(event) {

                // check
                if (this.self.columnData.style !== "aui-popup") {
                    return false;
                }

                let dataField = event.dataField;
                let yearMon = dataField.replace("a_", "").replace("_qty", "");
                let machine_name = event.item.machine_name;

                let param = {
                    "machine_plant_seq" : event.item.machine_plant_seq, // 모델번호
                    "s_area_code_str" : areaList, // 지역코드
                    "s_start_dt" : yearMon,
                    "s_end_dt" : yearMon,
                    "s_mem_no" : sMemNo, // 개인별 조회 시
                    "s_org_code" : $M.getValue("s_org_code"),
                    "s_gubun" : $M.getValue("s_gubun"),
                };

                // '기간내' 기간설정
				if (yearMon === "total") {
                    param.s_start_dt = sStartDt;
                    param.s_end_dt = sEndDt;
				}

                if (machine_name.includes("합계")) {
                    param.machine_plant_seq = "";
                    param.s_maker_cd = event.item.maker_cd;
                }

                // 전체총계
                if (machine_name.includes("총계")) {
                    param.machine_plant_seq = "";
                    param.s_maker_cd = ""; // 모든 메이커
                }

                // 얀마 소형/대형 합계
                if (event.item.maker_cd == "27" && (machine_name === "소형 합계" || machine_name === "대형 합계" )) {
                    param.s_yanmar_sub_type_cd = event.item.maker_weight_type;
                }

                $M.goNextPage('/sale/sale0406p01', $M.toGetParam(param), {popupStatus : ""});
			});

            // Default : 비율컬럼 Hide
            AUIGrid.hideColumnByDataField(auiGrid, hideList);
		}

        // 좌측 [영업지역/관할센터] 그리드 생성
        function createAUIGridArea() {

            const gridProsTree = {
                enableFilter: true,
                rowCheckDependingTree: true,
                showRowNumColumn: false,
                showRowAllCheckBox: true, // 전체 체크박스 표시 설정
                showRowCheckColumn: true, // 엑스트라 체크박스 표시 설정
            };

            const columnLayoutTree = [
                {
                    headerText: "마케팅지역",
                    dataField: "sale_area_name",
                    style: "aui-left",
                    editable: false,
                    width : "65%",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "관할센터",
                    dataField: "center_name",
                    style: "aui-center",
                    editable: false,
                    width : "35%",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "마케팅구역코드",
                    dataField: "sale_area_code",
                    visible: false
                },
            ];

            auiGridArea = AUIGrid.create("#auiGridArea", columnLayoutTree, gridProsTree);
            AUIGrid.setGridData(auiGridArea, ${areaList});
            $("#auiGridArea").resize();

            // 페이지 진입 시 그리드 전체 체크
            AUIGrid.setAllCheckedRows(auiGridArea, true);

            // 필터적용 후 전체선택 시 필터적용된 값만 체크되도록 수정
			fnFilterCheckAtTreeGrid(auiGridArea, "sale_area_code");
        }

		function myLabelFunction(rowIndex, columnIndex, value, headerText, item) {
			return value == "0" ? "" : $M.setComma(value);
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '수주잔고');
		}

        // 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
			// 조회 후 "펼침" 버튼 초기화
			$("input:checkbox[id='s_toggle_column']").attr("checked", false);
		}

        // 구분 Depth 1 >>> Depth 2 : 조직(org_code) 목록 조회
        function goSearchOrg(param) {

            if (param.value !== "") {
                $M.goNextPageAjax("/sale/sale0405/searchOrg/" + param.value, "", {method : "GET"},
                    function(result) {
                        if (result.success && result.list) {

                            $("select#s_org_code option").remove();
                            $('#s_org_code').append('<option value="">' + "- 전체 -" + '</option>');

                            // 결과값 세팅
                            result.list.forEach(l => {
                                const optVal = l.org_code;
                                const optText = l.org_kor_name;
                                $('#s_org_code').append('<option value="' + optVal + '">' + optText + '</option>');
                            })

                            // 구분 3 Depth 초기화
                            $("select#s_mem_no option").remove();
                            $('#s_mem_no').append('<option value="" >'+ "- 전체 -" +'</option>');

                            goSearch();
                        }
                    }
                );
            } else {
                // 구분 Depth 2 초기화
                $("select#s_org_code option").remove();
                $('#s_org_code').append('<option value="" >' + "- 전체 -" + '</option>');
                // 구분 Depth 3 초기화
                $("select#s_mem_no option").remove();
                $('#s_mem_no').append('<option value="" >' + "- 전체 -" + '</option>');
            }
        }

        // 구분 Depth 2 >>> Depth 3 : 해당 부서 직원 조회
        function goSearchMem(param) {

            if (param.value !== ""){
                $M.goNextPageAjax("/sale/sale0405/searchOrgMem/" + param.value, "", {method : "GET"},
                    function(result) {
                        if (result.success && result.list) {

                            $("select#s_mem_no option").remove();
                            $('#s_mem_no').append('<option value="" >'+ "- 전체 -" +'</option>');

                            // 결과값 세팅
                            result.list.forEach(data => {
                                const optVal = data.mem_no;
                                const optText = data.kor_name;
                                $('#s_mem_no').append('<option value="' + optVal + '">' + optText + '</option>');
                            });

                            goSearch();
                        }
                    }
                );
            }
            else {
                // 3 뎁스 초기화
                $("select#s_sale_org_mem option").remove();
                $('#s_sale_org_mem').append('<option value="" >' + "- 전체 -" + '</option>');
            }
        }

        // 펼침
        function fnChangeColumn(event) {

			const target = event.target || event.srcElement;
			if (!target)	return;

			const checked = target.checked;

            if (checked) {
                AUIGrid.showColumnByDataField(auiGrid, hideList);
            } else {
                AUIGrid.hideColumnByDataField(auiGrid, hideList);
            }
        }

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
    <div class="content-wrap">
        <div class="content-box">
            <!-- 메인 타이틀 -->
            <div class="main-title">
                <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            </div>
            <!-- /메인 타이틀 -->
            <div class="contents">
                <div class="row">
                    <!-- 좌측 영역 - 지역 그리드 -->
                    <div class="col-2">
                        <div id="auiGridArea" style="height: 650px;"></div>
                    </div>
                    <!-- 우측 영역 - 검색영역, 조회결과 그리드 -->
                    <div class="col-10">
                        <!-- 검색영역 -->
                        <div class="search-wrap">
                            <table class="table">
                                <colgroup>
                                    <col width="5%"> <!-- 조회년월 - 타이틀 -->
                                    <col width="15%"> <!-- 조회년월 - 년월 -->
                                    <col width="5%"> <!-- 구분 - 타이틀 -->
                                    <col width="30%"> <!-- 구분 - 부문, 센터, 담당자 -->
                                    <col width=""> <!-- 나머지 - 조회 버튼 -->
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th>조회년월</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-6">
                                                    <select class="form-control" id="s_end_year" name="s_end_year">
                                                        <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                                            <option value="${i}" <c:if test="${i == inputParam.s_date_year}">selected</c:if>>${i}년</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-4">
                                                    <select class="form-control" id="s_end_mon" name="s_end_mon">
                                                        <c:forEach var="i" begin="1" end="12" step="1">
                                                            <option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_date_mon}">selected</c:if>>${i}월</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                            </div>
									    </td>
                                        <th>구분</th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <div class="col-4">
                                                    <select class="form-control" id="s_gubun" name="s_gubun" onchange="goSearchOrg(this)">
                                                        <option value="">- 부문전체 -</option>
                                                        <c:forEach items="${codeMap['ORG_GUBUN']}" var="item">
                                                        <option value="${item.code_value}">
                                                            ${item.code_name}
                                                        </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-4">
                                                    <select class="form-control" id="s_org_code" name="s_org_code" onchange="goSearchMem(this)">
                                                        <option value="">- 센터전체 -</option>
                                                    </select>
                                                </div>
                                                <div class="col-4">
                                                    <select class="form-control" id="s_mem_no" name="s_mem_no" onchange="goSearch()">
                                                        <option value="">- 담당자전체 -</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="goSearch()">조회</button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <!-- /검색영역 -->
                        <!-- 그리드 타이틀, 컨트롤 영역 -->
                        <div class="title-wrap mt10">
                            <div class="left">
                                <h4>조회결과</h4>
                            </div>
                            <div class="btn-group">
                                <div class="right">
                                    <label for="s_toggle_column">
                                        <input type="checkbox" id="s_toggle_column" onclick="fnChangeColumn(event)">펼침
                                    </label>
                                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                                </div>
                            </div>
                        </div>
                        <!-- 그리드-->
                        <div id="auiGrid" style="margin-top: 5px; height: 568px;"></div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>
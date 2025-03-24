<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품마스터등록/수정 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	<script type="text/javascript">
		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		
		$(document).ready(function() {

			createAUIGrid();
		});
		
		// 페이지 이동
		function goAdd() {
// 			var param = {
// 				s_sort_key : "part_no",
// 				s_sort_method : "asc"
// 			};
			
			$M.goNextPage("/part/part070101", '');
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_part_no", "s_part_name", "s_maker_cd", "s_part_production_cd", "s_part_mng_cd", "s_code_desc", "s_part_group_cd", "s_use_yn"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		// 조회
		function goSearch() { 
			if( $M.getValue('s_part_no') == '' && $M.getValue('s_part_name') == '' && $M.getValue('s_maker_cd') == '' && $M.getValue('s_major_yn') == '') {
				alert('[부품번호, 부품명, 메이커, 주요부품] 중 하나는 필수 입력해주세요.');
				return;
			}
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}
		
		// 조회
		function fnSearch(successFunc) {
			isLoading = true;
			var param = {
				"s_part_no" : $M.getValue("s_part_no"),
				"s_part_name" : $M.getValue("s_part_name"),
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_part_production_cd" : $M.getValue("s_part_production_cd"),
				// "s_part_mng_cd" : $M.getValue("s_part_mng_cd"),
				"s_part_real_check_cd" : $M.getValue("s_part_real_check_cd"),
				"s_part_group_cd" : $M.getValue("s_part_group_cd"),
				"s_use_yn" : $M.getValue("s_use_yn"),
				"s_major_yn" : $M.getValue("s_major_yn") == "Y" ? "Y" : "N",
				"s_sort_key" : "part_no",
				"s_sort_method" : "asc",
				"page" : page,
				"rows" : $M.getValue("s_rows")
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					isLoading = false;
					if(result.success) {
						//console.log(result)
// 						AUIGrid.setGridData(auiGrid, result.list);
// 						$("#total_cnt").html(result.total_cnt);
						
						successFunc(result);
					};
				}
			);
		}
		
		// 메인그리드
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "part_no",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableFilter :true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// singleRow 선택모드
				selectionMode : "singleRow",
				height : "565"
			};
			var columnLayout = [ 
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "10%",
					style : "aui-center aui-link",
					editable : false,
					filter : {
						showIcon : true
					}
				}, {
					headerText : "부품명",
					dataField : "part_name",
					width : "28%",
					style : "aui-left",
					editable : false,
					filter : {
						showIcon : true
					}
				}, {
					headerText : "메이커",
					dataField : "maker_name",
					width : "10%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				}, {
					headerText : "생산구분",
					dataField : "part_production_name",
					width : "10%",
					style : "aui-center",
					editable : false
				},
				// {
				// 	headerText : "관리구분",
				// 	dataField : "part_mng_name",
				// 	width : "10%",
				// 	style : "aui-center",
				// 	editable : false
				// },
				// {
				// 	headerText : "분류코드",
				// 	dataField : "part_group_cd",
				// 	width : "10%",
				// 	style : "aui-center",
				// 	editable : false
				// },
				// 23.02.24 정윤수 부품마스터 리뉴얼로 인하여 변경
				{
					headerText : "부품구분",
					dataField : "part_group_cd",
					width : "10%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "분류구분",
					dataField : "part_real_check_cd",
					width : "10%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "분류명",
					dataField : "part_group_name",
					style : "aui-left",
					editable : false
				} 
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
	
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "part_no") {
					var param = {
							part_no : event.item.part_no
					};
					var poppupOption = "";
					$M.goNextPage('/part/part0701p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			// 제외항목
			//exceptColumnFields : ["removeBtn"]
			};
			fnExportExcel(auiGrid, "부품마스터", exportProps);
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
	<!-- 기본 -->
				<div class="search-wrap">
					<table class="table table-fixed">
						<colgroup>
							<col width="60px">
							<col width="120px">
							<col width="60px">
							<col width="120px">
							<col width="60px">
							<col width="80px">
							<col width="60px">
							<col width="70px">
							<col width="60px">
							<col width="100px">
							<col width="65px">
							<col width="190px">
							<col width="55px">
							<col width="75px">
							<col width="90px">
							<col width="90px">
							<col width="*">
						</colgroup>
						<tbody>
							<tr>
								<th>부품번호</th>
								<td>
									<input type="text" class="form-control" id="s_part_no" name="s_part_no"/>
								</td>
								<th>부품명</th>
								<td>
									<input type="text" class="form-control" id="s_part_name" name="s_part_name"/>
								</td>
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v2 == 'Y'}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<th>생산구분</th>
								<td>
									<select id="s_part_production_cd" name="s_part_production_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['PART_PRODUCTION']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
<%--								23.02.24 정윤수 부품마스터 리뉴얼로 인하여 변경--%>
<%--								<th>관리구분</th>--%>
<%--								<td>--%>
<%--									<select id="s_part_mng_cd" name="s_part_mng_cd" class="form-control">--%>
<%--										<option value="">- 전체 -</option>--%>
<%--										<c:forEach items="${codeMap['PART_MNG']}" var="item">--%>
<%--											<option value="${item.code_value}">${item.code_name}</option>--%>
<%--										</c:forEach>--%>
<%--									</select>--%>
<%--								</td>--%>
								<th>분류구분</th>
								<td>
									<select id="s_part_real_check_cd" name="s_part_real_check_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['PART_REAL_CHECK']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>부품구분</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col">
											<div class="input-group">
												<input type="text" id="s_part_group_cd" name="s_part_group_cd" style="width : 170px";
												 easyui="combogrid" easyuiname="partGroupCode" idfield="code_value"  textfield="code_name" multi="N" />
											
											</div>
										</div>
									</div>
								</td>
								<th>사용여부</th>
								<td>
									<select id="s_use_yn" name="s_use_yn" class="form-control">
										<option value="">- 전체 -</option>
										<option value="Y">사용</option>
										<option value="N">미사용</option>
									</select>
								</td>
								<th>			
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_major_yn" name="s_major_yn" value="Y">
									<label class="form-check-label mr5" for="s_major_yn">주요부품</label>
								</div>
								</th>								
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							<!-- <button type="button" class="btn btn-default"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button> -->
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->
				<div id="auiGrid" style="margin-top: 5px; height: 563px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<!-- /contents 전체 영역 -->	
</div>
</form>
</body>
</html>
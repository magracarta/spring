<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 사용안함
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	var auiGrid;
	$(document).ready(function () {
		createAUIGrid();
	});
	
	function createAUIGrid() {
		var gridPros = {
			// Row번호 표시 여부
			showRowNumColum : true
		};

		var columnLayout = [
			{
				headerText : "제품명",
				dataField : "a",
				style : "aui-center",
				width : "13%",
				editable : true
			},
			{
				headerText : "수량",
				dataField : "b",
				dataType : "numeric",
				style : "aui-center",
				formatString : "#,##0",
				width : "8%",
				editable : true
			},
			{
				headerText : "모델명",
				dataField : "c",
				style : "aui-center",
				width : "12%",
				editable : true
			},
			{
				headerText : "매입처",
				dataField : "d",
				style : "aui-center",
				width : "13%",
				editable : true
			},
			{
				headerText : "일련번호",
				dataField : "e",
				style : "aui-center",
				width : "17%",
				editable : true
			},
			{
				headerText : "렌탈일수",
				dataField : "f",
				dataType : "numeric",
				style : "aui-center",
				formatString : "#,##0",
				width : "15%",
				editable : true
			},
			{
				headerText : "렌탈금액",
				dataField : "g",  
				dataType : "numeric",
				style : "aui-center",
				formatString : "#,##0",
				width : "13%",
				editable : true
			},
			{
				headerText : "삭제",
				dataField : "h",
				width : "9%",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						AUIGrid.removeRow(event.pid, event.rowIndex);
						
					},
					visibleFunction : function(rowIndex, columnIndex, value, item, dataField ) {
						// 삭제버튼은 행 추가시에만 보이게 함
						
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false
			}
			
		];
		
		var dummyData = [
			{
				"a" : "대버켓",
				"b" : "1",
				"c" : "",
				"d" : "",
				"e" : "YMRVIO17KJY",
				"f" : "3",
				"g" : "0",
				"h" : "N"
			},
			{
				"a" : "대버켓",
				"b" : "1",
				"c" : "",
				"d" : "",
				"e" : "YMRVIO17KJY",
				"f" : "3",
				"g" : "0",
				"h" : "N"
			},
			{
				"a" : "대버켓",
				"b" : "1",
				"c" : "",
				"d" : "",
				"e" : "YMRVIO17KJY",
				"f" : "3",
				"g" : "0",
				"h" : "N"
			},
			{
				"a" : "대버켓",
				"b" : "1",
				"c" : "",
				"d" : "",
				"e" : "YMRVIO17KJY",
				"f" : "3",
				"g" : "0",
				"h" : "N"
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, dummyData);

		
	}
	
	//어태치먼트추가
	function go2() {
     	var params = {
	     	rental_machine_no : $M.getValue("rental_machine_no")
	    };
	    openRentalAttachPanel("fnSetAttach", $M.toGetParam(params));
    }
	
	//결재요청버튼
	function goRequestApproval() {
		alert("결재요청 버튼");
	}
	
	//결재처리버튼
	function goApproval() {
		alert("결재처리 버튼");
	}
	
	//수정버튼
	function goSave() {
		alert("저장버튼")
	}
	
	//렌탈장비대장버튼
	function goEquipment() {
		alert("렌탈장비대장");
	}
	
	//수리이력버튼
	function goRepairHistory() {
		alert("수리이력");
	}
	
	//닫기버튼
	function fnList() {
		history.back();
	}
	
	//이동처리
	function goMoveProcess() {
		alert("이동처리");
	}

	// 모델조회(단일)
	function goModelInfo() {
		var param = {};
		openSearchModelPanel('setModelInfo', 'N', $M.toGetParam(param));
	}
	
	//모델조회 test
	function setModelInfo(row) {
		alert(JSON.stringify(row));
	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
<!-- 상세페이지 타이틀 -->
			<div class="main-title detail">
				<div class="detail-left approval-left">
					<div class="left">
						<button type="button" onclick="fnList()" class="btn btn-outline-light"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
					<div>
						<span class="condition-item">상태 : 작성중</span>
					</div>
				</div>
<!-- 결재영역 -->
				<div class="pl10">
					<table class="table-border doc-table sm-table">
						<colgroup>
							<col width="80px">
							<col width="80px">
							<col width="80px">
							<col width="80px">
							<col width="80px">
						</colgroup>
						<tbody>
							<tr>	
								<th rowspan="2" class="title-bg th">
									<span class="v-align-middle">결재선</span>
									<button type="button" class="btn btn-primary-gra btn-sm">관리</button>
								</th>
								<th class="th">장현석</th>
								<th class="th">
									<div class="approval-table">
										<div class="input-area">
											<input type="text" style="width: 100%;">
											<button type="button" class="icon-btn-search"><i class="material-iconssearch"></i></button>
										</div>
										<div class="delete-area">
											<button type="button" class="icon-btn-close"><i class="material-iconsclose"></i></button>
										</div>
									</div>
								</th>
								<th class="th">
									<div class="approval-table">
										<div class="input-area">
											<input type="text" style="width: 100%;">
											<button type="button" class="icon-btn-search"><i class="material-iconssearch"></i></button>
										</div>
										<div class="delete-area">
											<button type="button" class="icon-btn-close"><i class="material-iconsclose"></i></button>
										</div>
									</div>
								</th>
								<th class="th">
									<div class="approval-table">
										<div class="input-area">
											<input type="text" style="width: 100%;">
											<button type="button" class="icon-btn-search"><i class="material-iconssearch"></i></button>
										</div>
										<div class="delete-area">
											<button type="button" class="icon-btn-close"><i class="material-iconsclose"></i></button>
										</div>
									</div>
								</th>
							</tr>
							<tr>					
								<td class="text-center td">작성중</td>
								<td class="text-center td"></td>
								<td class="text-center td"></td>
								<td class="text-center td"></td>
							</tr>
						</tbody>			
					</table>
				</div>
<!-- /결재영역 -->
			</div>
<!-- /상세페이지 타이틀 -->
			<div class="contents">			
				<div>
<!-- 폼테이블 1 -->				
					<table class="table-border">
						<colgroup>
							<col width="120px">
							<col width="">
							<col width="120px">
							<col width="">
							<col width="120px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">관리번호</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" class="form-control" readonly>
										</div>
										<div class="col width16px text-center">~</div>
										<div class="col width50px">
											<input type="text" class="form-control" readonly>
										</div>
									</div>
								</td>	
								<th class="text-right">요청일</th>
								<td>
									<div class="input-group width120px">
										<input type="text" class="form-control border-right-0 calDate" id="s_request_dt" name="s_request_dt" value="${inputParam.s_current_dt}" dateFormat="yyyy-MM-dd" alt="요청일">
									</div>
								</td>	
								<th class="text-right">요청센터</th>
								<td>
									<select class="form-control">
										<option>평택</option>
									</select>
								</td>	
							</tr>
							<tr>
								<th class="text-right">메이커</th>
								<td>
									<input type="text" class="form-control" readonly>				
								</td>	
								<th class="text-right">모델명</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" readonly>
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goModelInfo();" ><i class="material-iconssearch"></i></button>						
									</div>			
								</td>	
								<th class="text-right">요청자</th>
								<td>
									<input type="text" class="form-control width120px" readonly>				
								</td>
							</tr>
							<tr>
								<th class="text-right">연식</th>
								<td>
									<input type="text" class="form-control width50px" readonly>					
								</td>										
								<th class="text-right">가동시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" class="form-control" readonly>
										</div>
										<div class="col width33px">
											hr
										</div>
									</div>		
								</td>	
								<th class="text-right">출하일자</th>
								<td>
									<input type="text" class="form-control width120px" readonly>				
								</td>
							</tr>
							<tr>
								<th class="text-right">차대번호</th>
								<td>
									<input type="text" class="form-control" readonly>				
								</td>	
								<th class="text-right">GPS정보</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width33px text-right">
											종류
										</div>
										<div class="col width100px">
											<select class="form-control">
												<option>SA-R</option>
											</select>
										</div>
										<div class="col width60px text-right">
											개통번호
										</div>
										<div class="col width140px">
											<input type="text" class="form-control" readonly>
										</div>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
<!-- 폼테이블 1 -->	
<!-- 이동신청정보 -->				
					<div class="title-wrap mt10">
						<div class="left">
							<h4>이동신청정보</h4>
						</div>
						<div class="right">
							<button type="button" onclick="goEquipment();" class="btn btn-default">렌탈장비대장</button>
							<button type="button" onclick="goRepairHistory();" class="btn btn-default">수리이력</button>
						</div>
					</div>	
					<table class="table-border mt5">
						<colgroup>
							<col width="120px">
							<col width="">
							<col width="120px">
							<col width="">
							<col width="120px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">정산가격(판매)</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">어태치가격</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">장비가액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">중고시세가</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div> 
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">정산잔액(신청센터)</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">정산잔액(이동센터)</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">인도방법</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<select class="form-control">
												<option>직접인수</option>
											</select>
										</div>
										<div class="col width120px">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio">
												<label class="form-check-label">편도</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio">
												<label class="form-check-label">왕복</label>
											</div>
										</div>
									</div>
								</td>
								<th class="text-right">운송구분(신청자기준)</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio">
										<label class="form-check-label">선불</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio">
										<label class="form-check-label">착불</label>
									</div>
								</td>
								<th class="text-right">운송료</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>								
							<tr>
								<th class="text-right">배송지</th>
								<td colspan="5">
									<div class="form-row inline-pd">
										<div class="col-6">
											<input type="text" class="form-control">
										</div>
										<div class="col-6">
											<input type="text" class="form-control">
										</div>
									</div>										
								</td>
							</tr>
							<tr>
								<th class="text-right">비고</th>
								<td colspan="5">
									<textarea class="form-control" style="height: 70px;"></textarea>						
								</td>
							</tr>							
						</tbody>
					</table>
<!-- /이동신청정보 -->
					<div class="row">
						<div class="col-7">
<!-- 어태치먼트 구성 -->
							<div class="title-wrap mt10">
								<div class="left">
									<h4>어태치먼트 구성</h4>
								</div>
								<div class="right">
									<button type="button" onclick="go2()" class="btn btn-default"><i class="material-iconsadd text-default"></i> 어태치먼트추가</button>
								</div>
							</div>
							<div id="auiGrid" style="margin-top: 5px; height: 255px;"></div>
<!-- /어태치먼트 구성 -->
						</div>
						<div class="col-5">
<!-- 결재자의견 -->	
							<div class="title-wrap mt10">
								<div class="left">
									<h4>결재자의견</h4>
								</div>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<thead>
									<tr>
										<th>구분</th>
										<th>결재일시</th>
										<th>담당자</th>
										<th>특이사항</th>
									</tr>
								</thead>
								<tbody>
									<tr>
										<td>결재</td>							
										<td class="text-center">2019-07-01 10:39</td>	
										<td>장현석</td>							
										<td>결재합니다.</td>							
									</tr>
									<tr>
										<td></td>
										<td class="text-center"></td>	
										<td></td>	
										<td></td>										
									</tr>
									<tr>
										<td></td>
										<td class="text-center"></td>	
										<td></td>	
										<td></td>										
									</tr>	
									<tr>
										<td></td>
										<td class="text-center"></td>	
										<td></td>	
										<td></td>										
									</tr>	
									<tr>
										<td></td>
										<td class="text-center"></td>	
										<td></td>	
										<td></td>										
									</tr>	
									<tr>
										<td></td>
										<td class="text-center"></td>	
										<td></td>	
										<td></td>										
									</tr>									
								</tbody>			
							</table>
<!-- /결재자의견 -->		
						</div>
					</div>
				</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">					
					<div class="right">
						<button type="button" onclick="goRequestApproval();" class="btn btn-success">결재요청</button>
						<button type="button" onclick="goApproval();" class="btn btn-success">결재처리</button>
						<button type="button" onclick="goMoveProcess();" class="btn btn-info">이동처리</button>
						<button type="button" onclick="goSave();" class="btn btn-info">저장</button>
						<button type="button" onclick="fnList();" class="btn btn-info">목록</button>
					</div>
				</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>